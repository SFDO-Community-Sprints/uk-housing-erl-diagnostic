/**
 * @description Primary LWC Apex controller for the Easy Repair Locator. Exposes the full
 * category hierarchy, SOR retrieval, profile management, edit/delete operations, usage tracking,
 * and profile assignment. All write operations are guarded by AhaErlUtils.hasErlAdministrationPermission().
 */
public with sharing class AhaErlController {

    /** Sentinel profile name that is visible to all users and cannot be deleted. */
    public static final String ALL_PROFILE_NAME = 'ALL';

    /**
     * @description DTO representing a single category node returned to the LWC, including
     * its display labels, image reference, record type, and optional closeup button list.
     */
    public class SORResponse {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Boolean isGuided;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String editModeLabel;
        @AuraEnabled
        public String imageFileText;
        @AuraEnabled
        public String recordType;
        @AuraEnabled
        public string guidance;
        @AuraEnabled
        public boolean hasGuidance;
        @AuraEnabled
        public List<SORButtons> buttons;

        public SORResponse() {
            hasGuidance = false;
        }
    }

    /** @description DTO for a positioned repair-location button overlaid on a closeup image. */
    public class SORButtons {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Boolean isGuided;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String editModeLabel;
        @AuraEnabled
        public String layoutLeft;
        @AuraEnabled
        public String layoutTop;
        @AuraEnabled
        public String redirectToCategory;
    }

    /**
     * @description DTO for a selectable item list node, which can nest sub-categories, a flat
     * list of SOR codes, and an optional set of message-type codes.
     */
    public class AvailableSORList {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String editModeLabel;
        @AuraEnabled
        public Boolean selected;
        @AuraEnabled
        public List<AvailableSORList> subCategories;
        @AuraEnabled
        public List<AvailableSORs> sorList;
        @AuraEnabled
        public List<Message> messages;

        public AvailableSORList() {
            selected = false;
        }
    }

    /** @description DTO for a message-type SOR code shown inside an item picker item list. */
    public class Message {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String message;
    }

    /**
     * @description DTO for a selectable SOR code, carrying all fields needed for the picker UI
     * (code, description, heading, rate, trade, defaults) and the user-selected quantity/location.
     */
    public class AvailableSORs {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String sorCode;
        @AuraEnabled
        public String sorDescription;
        @AuraEnabled
        public Boolean selected;
        @AuraEnabled
        public Integer quantity;
        @AuraEnabled
        public String location;
        @AuraEnabled
        public String priority;
        @AuraEnabled
        public Decimal rate;
        @AuraEnabled
        public String heading;
        @AuraEnabled
        public String fullDescription;
        @AuraEnabled
        public String trade;

        public AvailableSORs() {
            selected = false;
            quantity = 1;
        }
    }

    /** @description DTO grouping SOR codes by their top-level category text field for the browse view. */
    public class BrowseSORCat {
        @AuraEnabled
        public String category;
        @AuraEnabled
        public List<BrowseSORSubCat> subCategories;

        public BrowseSORCat() {
            category = 'UNDEFINED';
            subCategories = new List<BrowseSORSubCat>();
        }
    }

    /** @description DTO grouping SOR codes by sub-category text within a BrowseSORCat. */
    public class BrowseSORSubCat {
        @AuraEnabled
        public String subCategory;
        @AuraEnabled
        public List<AvailableSORs> sorList;

        public BrowseSORSubCat() {
            subCategory = 'UNDEFINED';
            sorList = new List<AvailableSORs>();
        }
    }

    @AuraEnabled
    public static Boolean isSandbox() {
        return AhaErlUtils.isSandbox();
    }

    /**
     * @description Persists new X/Y percentage coordinates for a repair-location button category.
     * Called when an admin repositions a button on the closeup image.
     * @param params Map containing 'id' (record Id), 'x' (left %), and 'y' (top %)
     * @return Boolean true on success, false if an exception is thrown
     */
    @AuraEnabled
    public static Boolean updateSORCategoryCoords(Map<String, String> params) {
        try {
            Id recId = params.get('id');
            String x = params.get('x');
            String y = params.get('y');
            AHA_ERL_Category__c rsc = [SELECT Id, Layout_Left__c, Layout_Top__c 
                                             FROM AHA_ERL_Category__c 
                                             WHERE Id = :recId];
            rsc.Layout_Left__c = x;
            rsc.Layout_Top__c = y;
            update rsc;
        } catch (exception e) {
            return false;
        }
        return true;
    }

    /**
     * @description Returns all repair profiles ordered by name, used to populate the profile
     * selector in the picker and the profiles admin table.
     * @return List of AHA_ERL_Code_Profile__c records
     */
    @AuraEnabled
    public static List<AHA_ERL_Code_Profile__c> getAllProfiles() {
        return [SELECT Id, Name, Description__c, Guided__c 
                FROM AHA_ERL_Code_Profile__c 
                ORDER BY Name ASC];
    }

    /**
     * @description Returns the top-level (no parent) categories assigned to the given profile,
     * used to populate the root category tabs/buttons in the picker.
     * @param profileName Name of the repair profile to scope results to
     * @return List of SORResponse DTOs for root categories
     */
    @AuraEnabled
    public static List<SORResponse> getSORRootCategories(String profileName){
        List<AHA_ERL_Category__c> rsc = [SELECT Id, Label__c, EditModeLabel__c, ImageFileText__c, RecordType.DeveloperName, Guided__c 
                                                FROM AHA_ERL_Category__c 
                                                WHERE Id IN (SELECT SORCategory__c FROM AHA_ERL_Junction__c WHERE SORProfile__r.Name = :profileName AND SORCategory__r.HasParent__c = false)
                                                ORDER BY Label__c ASC];
        return wrapSORCategories(rsc);
    }

    /**
     * @description Returns child categories for the given parent category scoped to the given
     * profile. For RepairLocationCloseup record types, also attaches positioned button data and
     * profile-scoped guidance text to the response.
     * @param id Parent category Id to fetch children for
     * @param profileName Name of the repair profile to scope results to
     * @return List of SORResponse DTOs; for closeup types the first item carries buttons and guidance
     */
    @AuraEnabled
    public static List<SORResponse> getSORCategory(String id, String profileName){
        List<SORResponse> response = new List<SORResponse>();
        List<AHA_ERL_Category__c> rsc = [SELECT Id, EditModeLabel__c, Label__c, ImageFileText__c, RecordType.DeveloperName, Guided__c 
                                                FROM AHA_ERL_Category__c
                                                WHERE Id IN (SELECT SORCategory__c FROM AHA_ERL_Junction__c WHERE SORProfile__r.Name = :profileName AND SORCategory__r.ParentCategoryLookup__c = :id)
                                                ORDER BY Label__c ASC];
        response = wrapSORCategories(rsc);
        
        if (rsc.size() == 0) {
            return response;
        }
        
        if (rsc[0].RecordType.DeveloperName == 'RepairLocationCloseup') {
            //using [0] because only 1 closeup is expected. LWC warns the user if multiple closeups are found.
            String tempLeft = '5px';
            String tempTop = '5px';
            for (SORResponse sor : response) {
                
                
                List<AHA_ERL_Guidance__c> rguideList = [SELECT Guidance_Text__c 
                                                              FROM AHA_ERL_Guidance__c 
                                                              WHERE Id IN (SELECT Guidance__c 
                                                                           FROM AHA_ERL_Category_Guidance_Junction__c
                                                                           WHERE Category__c = :rsc[0].id
                                                                             AND Profile__r.Name = :profileName)
                                                              LIMIT 1];
                AHA_ERL_Guidance__c rguide = null;
                if (!rguideList.isEmpty()) {
                    rguide = rguideList[0];
                    response[0].hasGuidance = true;
                }
                if (rguide != null) {
                    sor.guidance = rguide.Guidance_Text__c;
                }
                sor.buttons = new List<SORButtons>();
                List<AHA_ERL_Category__c> buttons = [SELECT Id, Label__c, EditModeLabel__c, Layout_Left__c, Layout_Top__c, Guided__c, 
                                                                  RedirectToLookup__c, RedirectToLookup__r.Id, RedirectToLookup__r.EditModeLabel__c, RedirectToLookup__r.Label__c,
                                                                  RedirectToLookup__r.Layout_Left__c, RedirectToLookup__r.Layout_Top__c, RedirectToLookup__r.Guided__c,
                                                                  RedirectToLookup__r.RecordType.DeveloperName
                                                           FROM AHA_ERL_Category__c 
                                                           WHERE ParentCategoryLookup__c = :sor.id 
                                                             AND Id IN (SELECT SORCategory__c 
                                                                        FROM AHA_ERL_Junction__c 
                                                                        WHERE SORProfile__r.Name = :profileName)
                                                           ORDER BY Label__c ASC];
                for (AHA_ERL_Category__c button : buttons) {
                    SORButtons b = new SORButtons();

                    if (button.RedirectToLookup__c != null) {
                        if (button.RedirectToLookup__r.RecordType.DeveloperName == 'RepairCategory') {
                            b.id = b.Id;
                            b.redirectToCategory = button.RedirectToLookup__r.Id;
                            b.label = button.RedirectToLookup__r.Label__c;
                            b.editModeLabel = button.EditModeLabel__c;
                            b.isGuided = button.RedirectToLookup__r.Guided__c;
                        } else {
                            b.id = button.RedirectToLookup__r.Id;
                            b.label = button.RedirectToLookup__r.Label__c;
                            b.editModeLabel = button.RedirectToLookup__r.EditModeLabel__c;
                            b.isGuided = button.RedirectToLookup__r.Guided__c;
                        }
                    } else {
                        b.id = button.Id;
                        b.label = button.Label__c;
                        b.editModeLabel = button.EditModeLabel__c;
                        b.isGuided = button.Guided__c;
                    }

                    b.layoutLeft = button.Layout_Left__c == null ? tempLeft : button.Layout_Left__c;
                    if (button.Layout_Top__c == null) {
                        b.layoutTop = tempTop;
                        tempTop = String.valueOf(Integer.valueOf(tempTop.replace('px', '')) + 55) + 'px';
                    } else {
                        b.layoutTop = button.Layout_Top__c;
                    }
                    sor.buttons.add(b);
                }
            }
        }
        return response;
    }

    /**
     * @description Returns the hardcoded map of location codes to display labels used in the
     * repair location picker. TODO: replace with a dynamic data source.
     * @return Map of location code strings to human-readable location labels
     */
    @AuraEnabled
    public static Map<String, String> getLocations() {
        //todo hardcoded fix to something dynamic, this is just a temporary fix from being copied from original org
        return new Map<String, String>{
            'B1F - Bathroom 1st Floor' => 'B1F - Bathroom 1st Floor',
            'BAS - Basement' => 'BAS - Basement',
            'BD1 - Bedroom 1' => 'BD1 - Bedroom 1',
            'BD2 - Bedroom 2' => 'BD2 - Bedroom 2',
            'BD3 - Bedroom 3' => 'BD3 - Bedroom 3',
            'BD4 - Bedroom 4' => 'BD4 - Bedroom 4',
            'BD5 - Bedroom 5' => 'BD5 - Bedroom 5',
            'BGF - Bathroom Ground Floor' => 'BGF - Bathroom Ground Floor',
            'BIN - Bin Store' => 'BIN - Bin Store',
            'BLC - Balcony' => 'BLC - Balcony',
            'DIN - Dining Room' => 'DIN - Dining Room',
            'ERO - Extension Roof' => 'ERO - Extension Roof',
            'FEL - Front Elevation' => 'FEL - Front Elevation',
            'FGD - Front Garden' => 'FGD - Front Garden',
            'FLO - Front Lounge' => 'FLO - Front Lounge',
            'FRO - Front Roof' => 'FRO - Front Roof',
            'GRG - Garage' => 'GRG - Garage',
            'HLL - Hall' => 'HLL - Hall',
            'HSL - Hall Stairs Landing' => 'HSL - Hall Stairs Landing',
            'KIT - Kitchen' => 'KIT - Kitchen',
            'LDN - Landing' => 'LDN - Landing',
            'LFT - Loft' => 'LFT - Loft',
            'LIV - Living Room' => 'LIV - Living Room',
            'MTC - Meter Cupboard' => 'MTC - Meter Cupboard',
            'OTG - Outrigger' => 'OTG - Outrigger',
            'OUT - Outbuilding' => 'OUT - Outbuilding',
            'POR - Porch' => 'POR - Porch',
            'REL - Rear Elevation' => 'REL - Rear Elevation',
            'RGD - Rear Garden' => 'RGD - Rear Garden',
            'RLO - Rear Lounge' => 'RLO - Rear Lounge',
            'RRO - Rear Roof' => 'RRO - Rear Roof',
            'SEL - Side Elevation' => 'SEL - Side Elevation',
            'SGD - Side Garden' => 'SGD - Side Garden',
            'SHO - Shower Room' => 'SHO - Shower Room',
            'SRO - Side Roof' => 'SRO - Side Roof',
            'STR - Stairs' => 'STR - Stairs',
            'SWC - Separate WC' => 'SWC - Separate WC',
            'UNK - Unknown' => 'UNK - Unknown',
            'VAS - Ventilated Anti Space' => 'VAS - Ventilated Anti Space',
            'YRD - Yard' => 'YRD - Yard'
        };
    }

    /**
     * @description Builds the full item-picker payload for a selected repair button: fetches
     * item list and sub-category nodes under the button, then maps all profile-assigned SOR codes
     * and messages to those nodes.
     * @param id Id of the button-type AHA_ERL_Category__c record
     * @param profileName Name of the repair profile to scope SOR codes to
     * @return Nested list of AvailableSORList DTOs with sorList and messages populated
     */
    @AuraEnabled
    public static List<AvailableSORList> getSORsForButton(Id id, String profileName) {
        List<AHA_ERL_Category__c> rsc = [SELECT Id, Label__c, EditModeLabel__c
                                               FROM AHA_ERL_Category__c 
                                               WHERE ParentCategoryLookup__c = :id 
                                                 AND Id IN (SELECT SORCategory__c 
                                                            FROM AHA_ERL_Junction__c 
                                                            WHERE SORProfile__r.Name = :profileName 
                                                            AND SORCategory__c != null)];
        Set<Id> catids = new Set<Id>();
        for (AHA_ERL_Category__c r:rsc) {
            catids.add(r.Id);
        }
        List<AHA_ERL_Category__c> subCategories = [SELECT Id, Label__c, EditModeLabel__c, ParentCategoryLookup__c 
                                                         FROM AHA_ERL_Category__c 
                                                         WHERE ParentCategoryLookup__c IN :catids 
                                                           AND Id IN (SELECT SORCategory__c 
                                                                      FROM AHA_ERL_Junction__c 
                                                                      WHERE SORProfile__r.Name = :profileName 
                                                                      AND SORCategory__c != null)];
        for (AHA_ERL_Category__c r:subCategories) {
            catids.add(r.Id);
        }
        List<AHA_ERL_Category_Junction__c> junctionedSORs = [SELECT Id, 
                                                                          AHA_ERL_Category__c, 
                                                                          AHA_ERL_Code__r.Id, 
                                                                          AHA_ERL_Code__r.RecordType.DeveloperName,
                                                                          AHA_ERL_Code__r.Message__c,
                                                                          AHA_ERL_Code__r.SORCodeText__c, 
                                                                          AHA_ERL_Code__r.SORDescriptionText__c,
                                                                          AHA_ERL_Code__r.DefaultLocation__c,
                                                                          AHA_ERL_Code__r.DefaultPriority__c,
                                                                          AHA_ERL_Code__r.DefaultQuantity__c,
                                                                          AHA_ERL_Code__r.SORRateCurrency__c,
                                                                          AHA_ERL_Code__r.SORHeadingText__c,
                                                                          AHA_ERL_Code__r.SORFullDescriptionLongText__c,
                                                                          AHA_ERL_Code__r.Trade__c
                                                                   FROM AHA_ERL_Category_Junction__c 
                                                                   WHERE AHA_ERL_Category__c IN :catids
                                                                   AND AHA_ERL_Code__c IN (SELECT SORCode__c 
                                                                                                 FROM AHA_ERL_Junction__c 
                                                                                                 WHERE SORProfile__r.Name = :profileName)];
        Map<Id, List<AvailableSORs>> sorMap = new Map<Id, List<AvailableSORs>>();
        Map<Id, List<Message>> messageMap = new Map<Id, List<Message>>();
        for (AHA_ERL_Category_Junction__c j:junctionedSORs) {
            
            if (!sorMap.containsKey(j.AHA_ERL_Category__c)) {
                sorMap.put(j.AHA_ERL_Category__c, new List<AvailableSORs>());
            }
            if (!messageMap.containsKey(j.AHA_ERL_Category__c)) {
                messageMap.put(j.AHA_ERL_Category__c, new List<Message>());
            }
            if (j.AHA_ERL_Code__r.RecordType.DeveloperName == 'Message') {
                Message message = new Message();
                message.id = j.AHA_ERL_Code__r.Id;
                message.message = j.AHA_ERL_Code__r.Message__c;
                messageMap.get(j.AHA_ERL_Category__c).add(message);
            } else {
                AvailableSORs sor = new AvailableSORs();
                sor.id = j.AHA_ERL_Code__r.Id;
                sor.sorCode = j.AHA_ERL_Code__r.SORCodeText__c;
                sor.sorDescription = j.AHA_ERL_Code__r.SORDescriptionText__c;
                sor.location = j.AHA_ERL_Code__r.DefaultLocation__c;
                sor.priority = j.AHA_ERL_Code__r.DefaultPriority__c;
                sor.quantity = Integer.valueOf(j.AHA_ERL_Code__r.DefaultQuantity__c);
                sor.rate = j.AHA_ERL_Code__r.SORRateCurrency__c;
                sor.heading = j.AHA_ERL_Code__r.SORHeadingText__c;
                sor.fullDescription = j.AHA_ERL_Code__r.SORFullDescriptionLongText__c;
                sor.trade = j.AHA_ERL_Code__r.Trade__c;
                sorMap.get(j.AHA_ERL_Category__c).add(sor);
            }
        }
        List<AvailableSORList> response = new List<AvailableSORList>();
        for (AHA_ERL_Category__c r:rsc) {
            AvailableSORList asl = new AvailableSORList();
            asl.id = r.Id;
            asl.label = r.Label__c;
            asl.editModeLabel = r.EditModeLabel__c;
            asl.sorList = sorMap.get(r.Id);
            asl.messages = messageMap.get(r.Id);
            asl.subCategories = new List<AvailableSORList>();
            for (AHA_ERL_Category__c sub:subCategories) {
                if (sub.ParentCategoryLookup__c == r.Id) {
                    AvailableSORList aslSub = new AvailableSORList();
                    aslSub.id = sub.Id;
                    aslSub.label = sub.Label__c;
                    aslSub.editModeLabel = sub.EditModeLabel__c;
                    aslSub.sorList = sorMap.get(sub.Id);
                    aslSub.messages = messageMap.get(sub.Id);
                    asl.subCategories.add(aslSub);
                }
            }
            response.add(asl);
        }
        return response;
    }

    /**
     * @description Maps a list of AHA_ERL_Category__c records to SORResponse DTOs, defaulting
     * the image to 'PLACEHOLDER.jpg' when no image is set.
     * @param lrsc Raw category records to wrap
     * @return List of SORResponse DTOs
     */
    private static List<SORResponse> wrapSORCategories(List<AHA_ERL_Category__c> lrsc) {
        List<SORResponse> response = new List<SORResponse>();
        for (AHA_ERL_Category__c rsc : lrsc) {
            SORResponse sor = new SORResponse();
            sor.id = rsc.Id;
            sor.label = rsc.Label__c;
            sor.editModeLabel = rsc.EditModeLabel__c;
            sor.isGuided = rsc.Guided__c;
            sor.imageFileText = rsc.ImageFileText__c == null ? 'PLACEHOLDER.jpg' : rsc.ImageFileText__c;
            sor.recordType = rsc.RecordType.DeveloperName;
            response.add(sor);
        }
        return response;
    }

    /**
     * @description Returns all non-message SOR codes for the given profile, grouped by
     * Category and SubCategory text fields, for a hierarchical browse view.
     * @param profile Name of the repair profile to scope results to
     * @return List of BrowseSORCat DTOs, each containing sub-categories with SOR lists
     */
    @AuraEnabled (cacheable=true)
    public static List<BrowseSORCat> getAllSORForBrowse(String profile) {
        List<AHA_ERL_Junction__c> rsj = [SELECT Id, SORCode__c 
                                               FROM AHA_ERL_Junction__c 
                                               WHERE SORProfile__r.Name = :profile 
                                                 AND SORCode__c != null];
        Set<Id> sorIds = new Set<Id>();
        for (AHA_ERL_Junction__c r : rsj) {
            sorIds.add(r.SORCode__c);
        }
        List<AHA_ERL_Code__c> listSOR = [SELECT Id,
                                                      Category__c, 
                                                      SubCategory__c, 
                                                      SORCodeText__c, 
                                                      SORHeadingText__c, 
                                                      SORDescriptionText__c, 
                                                      SORRateCurrency__c, 
                                                      Trade__c, 
                                                      DefaultLocation__c,
                                                      DefaultPriority__c,
                                                      DefaultQuantity__c,
                                                      SORFullDescriptionLongText__c
                                               FROM AHA_ERL_Code__c
                                               WHERE RecordType.DeveloperName != 'Message'
                                               AND Id IN :sorIds];
        Map<String, Map<String, List<AvailableSORs>>> response = new Map<String, Map<String, List<AvailableSORs>>>();
        for (AHA_ERL_Code__c sor : listSOR) {
            if (!response.containsKey(sor.Category__c)) {
                response.put(sor.Category__c, new Map<String, List<AvailableSORs>>());
            }
            if (!response.get(sor.Category__c).containsKey(sor.SubCategory__c)) {
                response.get(sor.Category__c).put(sor.SubCategory__c, new List<AvailableSORs>());
            }
            AvailableSORs asor = new AvailableSORs();
            asor.id = sor.Id;
            asor.sorCode = sor.SORCodeText__c;
            asor.sorDescription = sor.SORDescriptionText__c;
            asor.rate = sor.SORRateCurrency__c;
            asor.trade = sor.Trade__c;
            asor.location = sor.DefaultLocation__c;
            asor.heading = sor.SORHeadingText__c;
            asor.priority = sor.DefaultPriority__c;
            asor.quantity = Integer.valueOf(sor.DefaultQuantity__c);
            asor.fullDescription = sor.SORFullDescriptionLongText__c;
            response.get(sor.Category__c).get(sor.SubCategory__c).add(asor);
        }
        List<BrowseSORCat> browseSOR = new List<BrowseSORCat>();
        for (String category : response.keySet()) {
            BrowseSORCat bsc = new BrowseSORCat();
            if (category == null) {
                bsc.category = 'UNDEFINED';
            } else {
                bsc.category = category;
            }
            bsc.subCategories = new List<BrowseSORSubCat>();
            for (String subCategory : response.get(category).keySet()) {
                BrowseSORSubCat bssc = new BrowseSORSubCat();
                if (subCategory == null) {
                    bssc.subCategory = 'UNDEFINED';
                } else {
                    bssc.subCategory = subCategory;
                }
                bssc.sorList = response.get(category).get(subCategory);
                bsc.subCategories.add(bssc);
            }
            browseSOR.add(bsc);
        }
        return browseSOR;
    }

    /**
     * @description Returns all non-message SOR codes for the given profile as a flat list
     * ordered by SOR code, used to power the client-side search component.
     * @param profile Name of the repair profile to scope results to
     * @return Flat list of AvailableSORs DTOs ordered by SORCodeText__c
     */
    @AuraEnabled
    public static List<AvailableSORs> getAllSORsForSearch(String profile) {
        List<AHA_ERL_Junction__c> rsj = [SELECT Id, SORCode__c 
                                               FROM AHA_ERL_Junction__c 
                                               WHERE SORProfile__r.Name = :profile 
                                                 AND SORCode__c != null];
        Set<Id> sorIds = new Set<Id>();
        for (AHA_ERL_Junction__c r : rsj) {
            sorIds.add(r.SORCode__c);
        }
        List<AHA_ERL_Code__c> listSOR = [SELECT Id,
                                                      Category__c, 
                                                      SubCategory__c, 
                                                      SORCodeText__c, 
                                                      SORHeadingText__c, 
                                                      SORDescriptionText__c, 
                                                      SORRateCurrency__c, 
                                                      Trade__c, 
                                                      DefaultLocation__c,
                                                      DefaultPriority__c,
                                                      DefaultQuantity__c,
                                                      SORFullDescriptionLongText__c
                                               FROM AHA_ERL_Code__c
                                               WHERE RecordType.DeveloperName != 'Message'
                                               AND Id IN :sorIds
                                               ORDER BY SORCodeText__c];
        List<AvailableSORs> response = new List<AvailableSORs>();
        for (AHA_ERL_Code__c sor : listSOR) {
            AvailableSORs asor = new AvailableSORs();
            asor.id = sor.Id;
            asor.sorCode = sor.SORCodeText__c;
            asor.sorDescription = sor.SORDescriptionText__c;
            asor.rate = sor.SORRateCurrency__c;
            asor.trade = sor.Trade__c;
            asor.location = sor.DefaultLocation__c;
            asor.heading = sor.SORHeadingText__c;
            asor.priority = sor.DefaultPriority__c;
            asor.quantity = Integer.valueOf(sor.DefaultQuantity__c);
            asor.fullDescription = sor.SORFullDescriptionLongText__c;
            response.add(asor);
        }
        
        return response;
    }

    /**
     * @description Returns the names of all profiles that have the given SOR code assigned
     * (via AHA_ERL_Junction__c with no category), used to pre-populate the profile picker in
     * the search-edit panel.
     * @param sor SORCodeText__c value to look up
     * @return List of profile name strings
     */
    @AuraEnabled
    public static List<String> getSORProfileAssignments(String sor) {
        List<AHA_ERL_Junction__c> rsj = [SELECT SORProfile__r.Name 
                                               FROM AHA_ERL_Junction__c 
                                               WHERE SORCode__r.SORCodeText__c = :sor
                                               AND SORCategory__c = null];
        List<String> response = new List<String>();
        for (AHA_ERL_Junction__c r : rsj) {
            response.add(r.SORProfile__r.Name);
        }
        return response;
    }

    /**
     * @description Replaces all profile junctions for the given SOR code (no-category rows) with
     * a fresh set matching the supplied profile list. Deletes removed profiles and inserts new ones.
     * @param profiles List of profile names to assign
     * @param sorCode SORCodeText__c value identifying the SOR to update
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String assignProfilestoSOR(List<String> profiles, String sorCode) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to assign profiles';
            }
            List<AHA_ERL_Junction__c> rsj = [SELECT Id 
                                                   FROM AHA_ERL_Junction__c 
                                                   WHERE SORCode__r.SORCodeText__c = :sorCode
                                                   AND SORCategory__c = null];
            delete rsj;
            List<AHA_ERL_Junction__c> rsjinserts = new List<AHA_ERL_Junction__c>();
            Id sorId = [SELECT Id 
                        FROM AHA_ERL_Code__c 
                        WHERE SORCodeText__c = :sorCode][0].Id;
            Map<String, Id> profileNameToId = new Map<String, Id>();
            for (AHA_ERL_Code_Profile__c r : [SELECT Id, Name 
                                                    FROM AHA_ERL_Code_Profile__c]) {
                profileNameToId.put(r.Name, r.Id);
            }
            for (String profile : profiles) {
                AHA_ERL_Junction__c rsjinsert = new AHA_ERL_Junction__c();
                rsjinsert.SORCode__c = sorId;
                rsjinsert.SORProfile__c = profileNameToId.get(profile);
                rsjinserts.add(rsjinsert);
            }
            insert rsjinserts;
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Assigned';
    }

    /**
     * @description Updates a category's label, edit-mode label, image, and guided flag, then
     * syncs its profile junctions via updateCategoryProfileJunctions.
     * @param details Map with keys: recid, label, editModeLabel, imageFileText, isGuided
     * @param profiles Target list of profile names for junction sync
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String editCategory(Map<String, String> details, List<String> profiles) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to edit this';
            }
            String recid = details.get('recid');
            AHA_ERL_Category__c rsc = [SELECT Id, Label__c, EditModeLabel__c, ImageFileText__c, Guided__c 
                                             FROM AHA_ERL_Category__c 
                                             WHERE Id = :recid];
            rsc.ImageFileText__c = details.get('imageFileText');
            rsc.Guided__c = Boolean.valueOf(details.get('isGuided'));
            rsc.Label__c = details.get('label');
            rsc.EditModeLabel__c = details.get('editModeLabel');
            update rsc;
            updateCategoryProfileJunctions(recid, profiles, false);
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Updated';
    }

    /**
     * @description Creates or updates rich-text guidance for a category/profile pair.
     * If a guidance junction already exists it updates the existing guidance record;
     * otherwise it creates both guidance and junction records.
     * @param categoryId Id of the AHA_ERL_Category__c closeup category
     * @param profileName Name of the profile the guidance should be scoped to
     * @param guidanceText Rich-text guidance body to persist
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String saveCategoryGuidance(String categoryId, String profileName, String guidanceText) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to edit this';
            }
            if (String.isBlank(categoryId) || String.isBlank(profileName)) {
                return 'error: categoryId and profileName are required';
            }

            List<AHA_ERL_Code_Profile__c> profiles = [SELECT Id
                                                      FROM AHA_ERL_Code_Profile__c
                                                      WHERE Name = :profileName
                                                      LIMIT 1];
            if (profiles.isEmpty()) {
                return 'error: profile not found';
            }
            Id profileId = profiles[0].Id;

            List<AHA_ERL_Category_Guidance_Junction__c> junctions = [SELECT Id, Guidance__c
                                                                      FROM AHA_ERL_Category_Guidance_Junction__c
                                                                      WHERE Category__c = :categoryId
                                                                        AND Profile__c = :profileId
                                                                      LIMIT 1];
            String finalGuidanceText = guidanceText == null ? '' : guidanceText;

            if (!junctions.isEmpty()) {
                AHA_ERL_Category_Guidance_Junction__c junction = junctions[0];
                if (junction.Guidance__c == null) {
                    AHA_ERL_Guidance__c newGuidance = new AHA_ERL_Guidance__c();
                    newGuidance.Guidance_Text__c = finalGuidanceText;
                    insert newGuidance;
                    junction.Guidance__c = newGuidance.Id;
                    update junction;
                } else {
                    AHA_ERL_Guidance__c guidance = [SELECT Id, Guidance_Text__c
                                                    FROM AHA_ERL_Guidance__c
                                                    WHERE Id = :junction.Guidance__c
                                                    LIMIT 1];
                    guidance.Guidance_Text__c = finalGuidanceText;
                    update guidance;
                }
            } else {
                AHA_ERL_Guidance__c guidance = new AHA_ERL_Guidance__c();
                guidance.Guidance_Text__c = finalGuidanceText;
                insert guidance;

                AHA_ERL_Category_Guidance_Junction__c junction = new AHA_ERL_Category_Guidance_Junction__c();
                junction.Category__c = categoryId;
                junction.Profile__c = profileId;
                junction.Guidance__c = guidance.Id;
                insert junction;
            }
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Updated';
    }

    /**
     * @description Updates the Message__c text of a message-type SOR code and syncs its profile
     * junctions via updateCategoryProfileJunctions.
     * @param recid Id of the AHA_ERL_Code__c message record
     * @param message New HTML message body
     * @param profiles Target list of profile names for junction sync
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String editMessage(String recid, String message, List<String> profiles) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to edit this';
            }
            AHA_ERL_Code__c rsc = [SELECT Id, Message__c 
                                         FROM AHA_ERL_Code__c 
                                         WHERE Id = :recid];
            rsc.Message__c = message;
            update rsc;
            updateCategoryProfileJunctions(recid, profiles, true);
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Updated';
    }

    /**
     * @description Performs a diff-based sync of AHA_ERL_Junction__c records for the given
     * category or SOR: deletes junctions for profiles no longer in the list (excluding 'ALL'),
     * and inserts junctions for newly added profiles.
     * @param recid Id of the category or SOR code to sync junctions for
     * @param profiles Desired set of profile names after the edit
     * @param isSOR true to operate on SORCode__c junctions, false for SORCategory__c junctions
     */
    private static void updateCategoryProfileJunctions(String recid, List<String> profiles, Boolean isSOR) {
        List<AHA_ERL_Junction__c> rsj = new List<AHA_ERL_Junction__c>();
        if (!isSOR) {
            rsj = [SELECT Id, SORProfile__r.Name 
                   FROM AHA_ERL_Junction__c 
                   WHERE SORCategory__c = :recid];
        } else {
            rsj = [SELECT Id, SORProfile__r.Name 
                   FROM AHA_ERL_Junction__c 
                   WHERE SORCode__c = :recid];
        }
        Set<String> profilesAll = new Set<String>();
        Set<String> profilesToDelete = new Set<String>();
        Set<String> profilesToAdd = new Set<String>();
        for (AHA_ERL_Junction__c r : rsj) {
            profilesAll.add(r.SORProfile__r.Name);
        }
        for (String profile : profiles) {
            if (!profilesAll.contains(profile)) {
                profilesToAdd.add(profile);
            }
        }
        for (String profile : profilesAll) {
            if (!profiles.contains(profile) && profile != ALL_PROFILE_NAME) {
                profilesToDelete.add(profile);
            }
        }
        List<AHA_ERL_Junction__c> toDelete = new List<AHA_ERL_Junction__c>();
        for (AHA_ERL_Junction__c r : rsj) {
            if (profilesToDelete.contains(r.SORProfile__r.Name)) {
                toDelete.add(r);
            }
        }
        List<AHA_ERL_Junction__c> toInsert = new List<AHA_ERL_Junction__c>();
        for (String profile : profilesToAdd) {
            AHA_ERL_Junction__c r = new AHA_ERL_Junction__c();
            if (isSOR) {
                r.SORCode__c = recid;
            } else {
                r.SORCategory__c = recid;
            }
            r.SORProfile__c = [SELECT Id 
                               FROM AHA_ERL_Code_Profile__c 
                               WHERE Name = :profile][0].Id;
            toInsert.add(r);
        }
        delete toDelete;
        insert toInsert;
    }

    /**
     * @description Removes the AHA_ERL_Category_Junction__c linking a message code to a category,
     * then asynchronously deletes the message code itself if it is no longer used anywhere.
     * @param recid Id of the AHA_ERL_Code__c message record
     * @param categoryId Id of the AHA_ERL_Category__c to unlink from
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String removeMessageFromCategory(String recid, String categoryId) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to remove this';
            }
            delete [SELECT Id 
                    FROM AHA_ERL_Category_Junction__c 
                    WHERE AHA_ERL_Category__c = :categoryId 
                      AND AHA_ERL_Code__c = :recid];
            removeOrphanedMessage(recid);
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Removed';
    }
    
    /**
     * @description Async cleanup: deletes a message AHA_ERL_Code__c record if it has no remaining
     * AHA_ERL_Category_Junction__c references. Runs @future to avoid mixed-DML issues.
     * @param msgName SORCodeText__c of the message record to check and potentially delete
     */
    @future
    private static void removeOrphanedMessage(String msgName) {
        List<AHA_ERL_Code__c> rsc = [SELECT Id 
                                           FROM AHA_ERL_Code__c 
                                           WHERE SORCodeText__c = :msgName];
        Set<Id> ids = new Set<Id>();
        for (AHA_ERL_Code__c r : rsc) {
            ids.add(r.Id);
        }
        List<AHA_ERL_Category_Junction__c> rscj = [SELECT Id 
                                                         FROM AHA_ERL_Category_Junction__c 
                                                         WHERE AHA_ERL_Code__c IN :ids];
        if (rscj.size() == 0) {
            delete rsc;
        }
    }

    /**
     * @description Creates a new AHA_ERL_Category__c with the given label, image, record type,
     * parent, and guided flag, then inserts AHA_ERL_Junction__c records for the target profiles
     * (always including ALL). Auto-creates the ALL profile if it does not exist and this is a
     * root-level category.
     * @param details Map with keys: parentId, label, editModeLabel, imageFileText, recordTypeDevName, isGuided
     * @param profiles List of profile names to assign the new category to
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String addCategory(Map<String, String> details, List<String> profiles) {
        Boolean isRootCategory = !details.containsKey('parentId') || String.isBlank(details.get('parentId'));
        Set<String> profileInserts = new Set<String>();
        for (String profile:profiles) {
            profileInserts.add(profile);
        }
        if (!profileInserts.contains(ALL_PROFILE_NAME)) {
            profileInserts.add(ALL_PROFILE_NAME);
        }
        String recordTypeDevName;
        if ((!details.containsKey('recordTypeDevName') || String.isBlank(details.get('recordTypeDevName')))) {
            recordTypeDevName = 'RepairCategory';
        } else {
            recordTypeDevName = details.get('recordTypeDevName');
        }
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to add this';
            }
            if (isRootCategory) {
                Integer allProfileCount = [SELECT COUNT()
                                           FROM AHA_ERL_Code_Profile__c
                                           WHERE Name = :ALL_PROFILE_NAME
                                              OR ExternalIdentifier__c = :ALL_PROFILE_NAME];
                if (allProfileCount == 0) {
                    AHA_ERL_Code_Profile__c allProfile = new AHA_ERL_Code_Profile__c();
                    allProfile.Name = ALL_PROFILE_NAME;
                    allProfile.ExternalIdentifier__c = ALL_PROFILE_NAME;
                    allProfile.Description__c = 'Admin: Displays every element';
                    insert allProfile;
                }
            }
            AHA_ERL_Category__c rsc = new AHA_ERL_Category__c();
            rsc.Label__c = details.get('label');
            rsc.ExternalIdentifier__c = 'RSORCat' + String.valueOf(Datetime.now().getTime());
            rsc.EditModeLabel__c = details.get('editModeLabel');
            rsc.Guided__c = Boolean.valueOf(details.get('isGuided'));
            rsc.ImageFileText__c = details.get('imageFileText');
            rsc.ParentCategoryLookup__c = details.get('parentId');
            rsc.RecordTypeId = [SELECT Id 
                                FROM RecordType 
                                WHERE DeveloperName = :recordTypeDevName 
                                  AND SobjectType = 'AHA_ERL_Category__c'][0].Id;
            insert rsc;
            List<AHA_ERL_Junction__c> rsjinserts = new List<AHA_ERL_Junction__c>();
            for (String profile : profileInserts) {
                AHA_ERL_Junction__c rsj = new AHA_ERL_Junction__c();
                rsj.SORCategory__c = rsc.Id;
                rsj.SORProfile__c = [SELECT Id 
                                     FROM AHA_ERL_Code_Profile__c 
                                     WHERE Name = :profile][0].Id;
                rsjinserts.add(rsj);
            }
            insert rsjinserts;
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Added';
    }

    /**
     * @description Deletes the given category record. Cascade delete rules on AHA_ERL_Junction__c
     * and AHA_ERL_Category_Junction__c handle child cleanup.
     * @param recid Id of the AHA_ERL_Category__c to delete
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String deleteCategory(String recid) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to delete this';
            }
            delete [SELECT Id 
                    FROM AHA_ERL_Category__c 
                    WHERE Id = :recid];
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Deleted';
    }

    /**
     * @description Creates an AHA_ERL_Category_Junction__c to link an existing SOR code to a
     * category node (item list or problem).
     * @param categoryId Id of the AHA_ERL_Category__c to link the SOR to
     * @param sor Id of the AHA_ERL_Code__c to link
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String addSORtoCategory(String categoryId, String sor) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to add this';
            }
            AHA_ERL_Category_Junction__c rscj = new AHA_ERL_Category_Junction__c();
            rscj.AHA_ERL_Category__c = categoryId;
            rscj.AHA_ERL_Code__c = sor;
            insert rscj;
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Added';
    }

    /**
     * @description Returns all message-type SOR code records for admins to choose from when
     * linking an existing message to a category. Returns null if the user is not an admin.
     * @return List of AHA_ERL_Code__c message records, or null if unauthorised
     */
    @AuraEnabled
    public static list<AHA_ERL_Code__c> getAllAvailableMessages() {
        if (!AhaErlUtils.hasErlAdministrationPermission()) {
            return null;
        }
        return [SELECT Id, SORCodeText__c, Message__c 
                FROM AHA_ERL_Code__c 
                WHERE RecordType.DeveloperName = 'Message'];
    }

    /**
     * @description Links an existing message code to a category via a new junction record, then
     * syncs the message's profile junctions to match the supplied list.
     * @param categoryId Id of the AHA_ERL_Category__c to attach the message to
     * @param msgId Id of the existing AHA_ERL_Code__c message record
     * @param profiles List of profile names to assign the message to
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String addExistingMessageToCategory(String categoryId, String msgId, List<String> profiles) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to add this';
            }
            AHA_ERL_Category_Junction__c rscj = new AHA_ERL_Category_Junction__c();
            rscj.AHA_ERL_Category__c = categoryId;
            rscj.AHA_ERL_Code__c = msgId;
            insert rscj;
            updateCategoryProfileJunctions(msgId, profiles, true);
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Added';
    }

    /**
     * @description Creates a new message-type AHA_ERL_Code__c, links it to the category via a
     * junction record, then syncs its profile junctions.
     * @param categoryId Id of the AHA_ERL_Category__c to attach the message to
     * @param msgName Name/code text for the new message record
     * @param message HTML body of the message
     * @param profiles List of profile names to assign the message to
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String addMessagetoCategory(String categoryId, String msgName, String message, List<String> profiles) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to add this';
            }
            AHA_ERL_Code__c rsc = new AHA_ERL_Code__c();
            rsc.SORCodeText__c = msgName;
            rsc.Message__c = message;
            rsc.RecordTypeId = [SELECT Id 
                                FROM RecordType 
                                WHERE DeveloperName = 'Message' 
                                  AND SobjectType = 'AHA_ERL_Code__c'][0].Id;
            insert rsc;
            AHA_ERL_Category_Junction__c rscj = new AHA_ERL_Category_Junction__c();
            rscj.AHA_ERL_Category__c = categoryId;
            rscj.AHA_ERL_Code__c = rsc.Id;
            insert rscj;
            updateCategoryProfileJunctions(rsc.Id, profiles, true);
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Added';
    }

    /**
     * @description Removes the AHA_ERL_Category_Junction__c linking a SOR code to a category
     * node. Does not delete the SOR code itself.
     * @param categoryId Id of the AHA_ERL_Category__c to unlink from
     * @param sor Id of the AHA_ERL_Code__c to unlink
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String removeSORfromCategory(String categoryId, String sor) {
        if (categoryId == null || sor == null) {
            return 'error: categoryId or sor is null';
        }
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'you do not have permission to remove this';
            }
            delete [SELECT Id 
                    FROM AHA_ERL_Category_Junction__c 
                    WHERE AHA_ERL_Category__c = :categoryId 
                      AND AHA_ERL_Code__c = :sor];
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Removed';
    }

    /**
     * @description Creates a new empty repair profile with no SOR or category assignments.
     * @param newName Name for the new AHA_ERL_Code_Profile__c record
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String newBlankProfile(String newName) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'error: you do not have permission to add this';
            }
            AHA_ERL_Code_Profile__c rscp = new AHA_ERL_Code_Profile__c();
            rscp.Name = newName;
            rscp.ExternalIdentifier__c = newName;
            insert rscp;
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Added';
    }
    
    /**
     * @description Creates a new repair profile and bulk-copies all AHA_ERL_Junction__c records
     * from the source profile to the new one, preserving both SOR and category assignments.
     * @param profileName Source profile name to clone from
     * @param newDesc Description for the new profile
     * @param newName Name for the new profile
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String cloneProfile(String profileName, String newDesc, String newName) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'error: you do not have permission to clone this';
            }
            AHA_ERL_Code_Profile__c rscp = new AHA_ERL_Code_Profile__c();
            rscp.Name = newName;
            rscp.ExternalIdentifier__c = newName;
            rscp.Description__c = newDesc;
            insert rscp;
            List<AHA_ERL_Junction__c> newJunctions = new List<AHA_ERL_Junction__c>();
            for (AHA_ERL_Junction__c j:[SELECT Id, SORCategory__c, SORCode__c, SORProfile__c 
                                              FROM AHA_ERL_Junction__c 
                                              WHERE SORProfile__r.Name = :profileName]) {
                AHA_ERL_Junction__c newJ = new AHA_ERL_Junction__c();
                newJ.SORCategory__c = j.SORCategory__c;
                newJ.SORCode__c = j.SORCode__c;
                newJ.SORProfile__c = rscp.Id;
                newJunctions.add(newJ);
            }
            insert newJunctions;
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Cloned';
    }

    /**
     * @description Deletes the named repair profile. Guards against deletion of the 'ALL'
     * sentinel and the 'Default' profile.
     * @param profileName Name of the AHA_ERL_Code_Profile__c to delete
     * @return Success message string or an 'error: ...' string on failure or protection violation
     */
    @AuraEnabled
    public static String deleteProfile(String profileName) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'error: you do not have permission to delete this';
            }
            if (profileName == ALL_PROFILE_NAME) {
                return 'error: Cannot delete all-container profile';
            }
            if (profileName == 'Default') {
                return 'error: Cannot delete default profile';
            }
            delete [SELECT Id 
                    FROM AHA_ERL_Code_Profile__c 
                    WHERE Name = :profileName];
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Deleted';
    }

    /**
     * @description Returns the names of all profiles currently junctioned to the given category
     * or SOR code, used to pre-populate the profile picker when opening the edit panel.
     * @param categoryId Id of the AHA_ERL_Category__c or AHA_ERL_Code__c to query
     * @param isSor true to query by SORCode__c, false to query by SORCategory__c
     * @return List of profile name strings
     */
    @AuraEnabled
    public static List<String> getCurrentJunctionedProfiles(String categoryId, Boolean isSor) {
        List<String> response = new List<String>();
        List<AHA_ERL_Junction__c> rsj = new List<AHA_ERL_Junction__c>();
        if (isSor) {
            rsj = [SELECT SORProfile__r.Name 
                   FROM AHA_ERL_Junction__c 
                   WHERE SORCode__c = :categoryId];
        } else {
            rsj = [SELECT SORProfile__r.Name 
                   FROM AHA_ERL_Junction__c 
                   WHERE SORCategory__c = :categoryId];
        }
        for (AHA_ERL_Junction__c r : rsj) {
            response.add(r.SORProfile__r.Name);
        }
        return response;
    }

    /**
     * @description LWC entry point for usage tracking — delegates immediately to an @future
     * method to avoid mixed-DML restrictions when called from a component that also performs DML.
     * @param path Navigation path string accumulated during the session
     * @param itime Elapsed seconds as a string
     * @param profile Active repair profile name
     * @param item SOR code or action label of the final selection
     * @param type 'GUIDED' or 'DIAGNOSTIC'
     * @param trackerType 'PARTIAL' for mid-session events, 'COMPLETE' for final submission
     */
    @AuraEnabled
    public static void logTracking(String path, String itime, String profile, String item, String type, String trackerType){
        logTrackingAsync(path, itime, profile, item, type, trackerType);   
    }

    /**
     * @description Inserts an AHA_ERL_Usage_Tracker__c record asynchronously. Runs @future
     * to decouple tracking DML from the calling transaction.
     */
    @future
    public static void logTrackingAsync(String path, String itime, String profile, String item, String type, String trackerType){
        AHA_ERL_Usage_Tracker__c rt = new AHA_ERL_Usage_Tracker__c();
        rt.PathTaken__c = path;
        rt.TimeTaken__c = Decimal.valueOf(itime);
        rt.Profile__c = profile;
        rt.ItemSelected__c = item;
        rt.Type__c = type;
        rt.TrackerType__c = trackerType;
        insert rt;
    }

    /**
     * @description Returns every non-message SOR code with a boolean indicating whether it is
     * currently assigned to the given profile. Used to power the profile assignment admin UI.
     * @param profileName Name of the profile to check assignments against
     * @return List of AvailableSORs DTOs with the selected field set to the current assignment state
     */
    @AuraEnabled
    public static List<AvailableSORs> getAllSORsWithAssignment(String profileName) {
        List<AHA_ERL_Code__c> allSORs = [SELECT Id, SORCodeText__c, SORDescriptionText__c, SORRateCurrency__c, Trade__c, 
                                                    DefaultLocation__c, DefaultPriority__c, DefaultQuantity__c, SORFullDescriptionLongText__c,
                                                    SORHeadingText__c
                                               FROM AHA_ERL_Code__c
                                               WHERE RecordType.DeveloperName != 'Message'
                                               ORDER BY SORCodeText__c];
        
        Set<Id> assignedSORIds = new Set<Id>();
        for (AHA_ERL_Junction__c junction : [SELECT SORCode__c FROM AHA_ERL_Junction__c WHERE SORProfile__r.Name = :profileName AND SORCode__C != null AND SORCategory__c = null]) {
            assignedSORIds.add(junction.SORCode__c);
        }

        List<AvailableSORs> response = new List<AvailableSORs>();
        for (AHA_ERL_Code__c sor : allSORs) {
            AvailableSORs asor = new AvailableSORs();
            asor.id = sor.Id;
            asor.sorCode = sor.SORCodeText__c;
            asor.sorDescription = sor.SORDescriptionText__c;
            asor.rate = sor.SORRateCurrency__c;
            asor.trade = sor.Trade__c;
            asor.location = sor.DefaultLocation__c;
            asor.heading = sor.SORHeadingText__c;
            asor.priority = sor.DefaultPriority__c;
            asor.quantity = Integer.valueOf(sor.DefaultQuantity__c);
            asor.fullDescription = sor.SORFullDescriptionLongText__c;
            asor.selected = assignedSORIds.contains(sor.Id);
            response.add(asor);
        }
        return response;
    }

    /**
     * @description Creates a direct SOR-to-profile AHA_ERL_Junction__c (no category) to mark
     * the SOR as assigned to the profile in the assignment admin UI.
     * @param profileName Name of the profile to assign to
     * @param sorId Id of the AHA_ERL_Code__c to assign
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String addSORAssignment(String profileName, String sorId) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'error: you do not have permission to add this assignment';
            }
            Id profileId = [SELECT Id FROM AHA_ERL_Code_Profile__c WHERE Name = :profileName LIMIT 1].Id;
            AHA_ERL_Junction__c newAssignment = new AHA_ERL_Junction__c();
            newAssignment.SORProfile__c = profileId;
            newAssignment.SORCode__c = sorId;
            insert newAssignment;
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Assigned';
    }

    /**
     * @description Deletes the direct SOR-to-profile AHA_ERL_Junction__c to unassign the SOR
     * from the profile in the assignment admin UI.
     * @param profileName Name of the profile to unassign from
     * @param sorId Id of the AHA_ERL_Code__c to unassign
     * @return Success message string or an 'error: ...' string on failure
     */
    @AuraEnabled
    public static String removeSORAssignment(String profileName, String sorId) {
        try {
            if (!AhaErlUtils.hasErlAdministrationPermission()) {
                return 'error: you do not have permission to remove this assignment';
            }
            Id profileId = [SELECT Id FROM AHA_ERL_Code_Profile__c WHERE Name = :profileName LIMIT 1].Id;
            delete [SELECT Id FROM AHA_ERL_Junction__c WHERE SORProfile__c = :profileId AND SORCode__c = :sorId LIMIT 1];
        } catch (exception e) {
            return 'error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
        }
        return 'Successfully Removed';
    }
}
# AHA_ERL_Example_Flow history

<!-- This page has been generated to be viewed with mkdocs-material, you can not view it just as markdown . Activate tab plugin following the doc at https://squidfunk.github.io/mkdocs-material/reference/content-tabs/ -->

=== "Jun 16, 2026 (Initial)"

    _Jun 16, 2026, by Matthew McMahon in commit example flow_

    
    ## Flow Diagram
    
    ```mermaid
    %% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
    %% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
    %% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
    %% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
    %% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram
    
    flowchart TB
    START(["START<br/><b>Screen Flow</b>"]):::startClass
    click START "#general-information" "2831166408"
    
    Decision_1{"🔀 <em></em><br/>Does a Category Exist"}:::decisions
    click Decision_1 "#decision_1" "1552536510"
    
    Get_ERL_Profiles[("🔍 <em></em><br/>Get ERL Profiles")]:::recordLookups
    click Get_ERL_Profiles "#get_erl_profiles" "3869691587"
    
    test_get_categories[("🔍 <em></em><br/>test get categories")]:::recordLookups
    click test_get_categories "#test_get_categories" "1527761578"
    
    Choose_Profile(["💻 <em></em><br/>Choose Profile"]):::screens
    click Choose_Profile "#choose_profile" "513751878"
    
    ERL_Picker_Example_Start_Screen(["💻 <em></em><br/>ERL Picker Example Start Screen"]):::screens
    click ERL_Picker_Example_Start_Screen "#erl_picker_example_start_screen" "186655686"
    
    ERL_Picker_Exit_Screen_Example(["💻 <em></em><br/>ERL Picker Exit Screen Example"]):::screens
    click ERL_Picker_Exit_Screen_Example "#erl_picker_exit_screen_example" "3528031833"
    
    No_Categories_Error(["💻 <em></em><br/>No Categories Error"]):::screens
    click No_Categories_Error "#no_categories_error" "284205707"
    
    Decision_1 --> |"At Least 1 Category Found"| Get_ERL_Profiles
    Decision_1 --> |"No Category Found"| No_Categories_Error
    Get_ERL_Profiles --> Choose_Profile
    test_get_categories --> Decision_1
    Choose_Profile --> ERL_Picker_Example_Start_Screen
    ERL_Picker_Example_Start_Screen --> ERL_Picker_Exit_Screen_Example
    ERL_Picker_Exit_Screen_Example --> END_ERL_Picker_Exit_Screen_Example
    No_Categories_Error --> END_No_Categories_Error
    START -->  test_get_categories
    END_ERL_Picker_Exit_Screen_Example(( END )):::endClass
    END_No_Categories_Error(( END )):::endClass
    
    
    classDef actionCalls fill:#D4E4FC,color:black,text-decoration:none,max-height:100px
    classDef assignments fill:#FBEED7,color:black,text-decoration:none,max-height:100px
    classDef collectionProcessors fill:#F0E3FA,color:black,text-decoration:none,max-height:100px
    classDef customErrors fill:#FFE9E9,color:black,text-decoration:none,max-height:100px
    classDef decisions fill:#FDEAF6,color:black,text-decoration:none,max-height:100px
    classDef loops fill:#FDEAF6,color:black,text-decoration:none,max-height:100px
    classDef recordCreates fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
    classDef recordDeletes fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
    classDef recordLookups fill:#EDEAFF,color:black,text-decoration:none,max-height:100px
    classDef recordRollbacks fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
    classDef recordUpdates fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
    classDef screens fill:#DFF6FF,color:black,text-decoration:none,max-height:100px
    classDef subflows fill:#D4E4FC,color:black,text-decoration:none,max-height:100px
    classDef startClass fill:#D9F2E6,color:black,text-decoration:none,max-height:100px
    classDef endClass fill:#F9BABA,color:black,text-decoration:none,max-height:100px
    classDef transforms fill:#FDEAF6,color:black,text-decoration:none,max-height:100px
    
    
    ```
    
    <!-- Flow description -->
    
    ## General Information
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Process Type| Flow|
    |Label|AHA-ERL Example Flow|
    |Status|⚠️ Draft|
    |Environments|Default|
    |Interview Label|AHA-ERL Example Flow {!$Flow.CurrentDateTime}|
    | Builder Type (PM)|LightningFlowBuilder|
    | Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
    | Origin Builder Type (PM)|LightningFlowBuilder|
    |Connector|[test_get_categories](#test_get_categories)|
    |Next Node|[test_get_categories](#test_get_categories)|
    
    
    ## Variables
    
    |Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
    |:-- |:--:|:--:|:--:|:--:|:--:|:--  |
    |apex_objectOutput|Apex|⬜|⬜|⬜|<!-- -->|<!-- -->|
    |collection_selectedLines|Apex|✅|⬜|⬜|<!-- -->|<!-- -->|
    |text_JSONOutput|String|⬜|⬜|⬜|<!-- -->|<!-- -->|
    
    
    ## Flow Nodes Details
    
    ### Decision_1
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Type|Decision|
    |Label|Does a Category Exist|
    |Description|This is to warn the user if ERL hasn't got any setup to actually display in this flow yet|
    |Default Connector|[No_Categories_Error](#no_categories_error)|
    |Default Connector Label|No Category Found|
    
    
    #### Rule Outcome_1_of_Decision_1 (At Least 1 Category Found)
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Connector|[Get_ERL_Profiles](#get_erl_profiles)|
    |Condition Logic|and|
    
    
    
    
    |Condition Id|Left Value Reference|Operator|Right Value|
    |:-- |:-- |:--:|:--: |
    |1|[test_get_categories](#test_get_categories)| Is Null|⬜|
    
    
    
    
    ### Get_ERL_Profiles
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Type|Record Lookup|
    |Object|AHA_ERL_Code_Profile__c|
    |Label|Get ERL Profiles|
    |Assign Null Values If No Records Found|⬜|
    |Get First Record Only|⬜|
    |Queried Fields|- Id<br/>- Name<br/>|
    |Store Output Automatically|✅|
    |Connector|[Choose_Profile](#choose_profile)|
    
    
    #### Filters (logic: **and**)
    
    |Filter Id|Field|Operator|Value|
    |:-- |:-- |:--:|:--: |
    |1|Id| Not Equal To|<!-- -->|
    
    
    
    
    ### test_get_categories
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Type|Record Lookup|
    |Object|AHA_ERL_Category__c|
    |Label|test get categories|
    |Assign Null Values If No Records Found|⬜|
    |Get First Record Only|✅|
    |Store Output Automatically|✅|
    |Connector|[Decision_1](#decision_1)|
    
    
    #### Filters (logic: **and**)
    
    |Filter Id|Field|Operator|Value|
    |:-- |:-- |:--:|:--: |
    |1|Id| Not Equal To|<!-- -->|
    
    
    
    
    ### Choose_Profile
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Type|Screen|
    |Label|Choose Profile|
    |Allow Back|✅|
    |Allow Finish|✅|
    |Allow Pause|✅|
    |Show Footer|✅|
    |Show Header|✅|
    |Connector|[ERL_Picker_Example_Start_Screen](#erl_picker_example_start_screen)|
    
    
    #### ProfileSelection
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Data Type|String|
    |Choice References|collection_choice_ProfilesList|
    |Field Text|Profile|
    |Field Type| Dropdown Box|
    |Inputs On Next Nav To Assoc Scrn| Use Stored Values|
    |Is Required|✅|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    
    
    
    
    ### ERL_Picker_Example_Start_Screen
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Type|Screen|
    |Label|ERL Picker Example Start Screen|
    |Allow Back|✅|
    |Allow Finish|✅|
    |Allow Pause|✅|
    |Show Footer|⬜|
    |Show Header|✅|
    |Connector|[ERL_Picker_Exit_Screen_Example](#erl_picker_exit_screen_example)|
    
    
    #### ERLPickerFlow
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Extension Name|c:ahaErlPicker|
    |Field Type| Component Instance|
    |Inputs On Next Nav To Assoc Scrn| Use Stored Values|
    |Is Required|✅|
    |Output Parameters|- assignToReference: text_JSONOutput<br/>&nbsp;&nbsp;name: outputTextJSON<br/>- assignToReference: apex_objectOutput<br/>&nbsp;&nbsp;name: outputApex<br/>|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    |Address Text (input)|1 test avenue|
    |Repair Profile (input)|ProfileSelection|
    
    
    
    
    ### ERL_Picker_Exit_Screen_Example
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Type|Screen|
    |Label|ERL Picker Exit Screen Example|
    |Allow Back|✅|
    |Allow Finish|✅|
    |Allow Pause|✅|
    |Show Footer|✅|
    |Show Header|✅|
    
    
    #### ToggleOutputDIsplay
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Extension Name|flowruntime:toggle|
    |Field Type| Component Instance|
    |Inputs On Next Nav To Assoc Scrn| Use Stored Values|
    |Is Required|✅|
    |Store Output Automatically|✅|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    |Message Toggle Inactive (input)|Show JSON Output|
    |Message Toggle Active (input)|Show Object Output|
    
    
    
    
    #### User
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Data Type|String|
    |Default Value|apex_objectOutput.userName|
    |Field Text|User|
    |Field Type| Input Field|
    |Inputs On Next Nav To Assoc Scrn| Use Stored Values|
    |Is Read Only|true|
    |Is Required|⬜|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    |Parent Field|[ERL_Picker_Exit_Screen_Example_Section1_Column1](#erl_picker_exit_screen_example_section1_column1)|
    
    
    
    
    #### Timestamp_Selected
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Data Type|String|
    |Default Value|apex_objectOutput.timestamp|
    |Field Text|Timestamp Selected|
    |Field Type| Input Field|
    |Inputs On Next Nav To Assoc Scrn| Use Stored Values|
    |Is Read Only|true|
    |Is Required|⬜|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    |Parent Field|[ERL_Picker_Exit_Screen_Example_Section1_Column1](#erl_picker_exit_screen_example_section1_column1)|
    
    
    
    
    #### ERL_Picker_Exit_Screen_Example_Section1_Column1
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Field Type| Region|
    |Is Required|⬜|
    |Parent Field|[ERL_Picker_Exit_Screen_Example_Section1](#erl_picker_exit_screen_example_section1)|
    |Width (input)|6|
    
    
    
    
    #### UserId
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Data Type|String|
    |Default Value|apex_objectOutput.userId|
    |Field Text|UserId|
    |Field Type| Input Field|
    |Inputs On Next Nav To Assoc Scrn| Use Stored Values|
    |Is Read Only|true|
    |Is Required|⬜|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    |Parent Field|[ERL_Picker_Exit_Screen_Example_Section1_Column2](#erl_picker_exit_screen_example_section1_column2)|
    
    
    
    
    #### ERL_Picker_Exit_Screen_Example_Section1_Column2
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Field Type| Region|
    |Is Required|⬜|
    |Parent Field|[ERL_Picker_Exit_Screen_Example_Section1](#erl_picker_exit_screen_example_section1)|
    |Width (input)|6|
    
    
    
    
    #### ERL_Picker_Exit_Screen_Example_Section1
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Field Type| Region Container|
    |Is Required|⬜|
    |Region Container Type| Section Without Header|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    |Visibility Rule|conditionLogic: or<br/>conditions:<br/>&nbsp;&nbsp;- leftValueReference: ToggleOutputDIsplay.value<br/>&nbsp;&nbsp;&nbsp;&nbsp;operator: EqualTo<br/>&nbsp;&nbsp;&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;booleanValue: false<br/>&nbsp;&nbsp;- leftValueReference: ToggleOutputDIsplay.value<br/>&nbsp;&nbsp;&nbsp;&nbsp;operator: IsNull<br/>&nbsp;&nbsp;&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;booleanValue: true<br/>|
    
    
    
    
    #### SORSInSelection
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Data Type Mappings|apexClass: AhaErlFlowOutputLine<br/>typeName: T<br/>|
    |Extension Name|flowruntime:datatable|
    |Field Type| Component Instance|
    |Inputs On Next Nav To Assoc Scrn| Use Stored Values|
    |Is Required|✅|
    |Store Output Automatically|✅|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    |Visibility Rule|conditionLogic: or<br/>conditions:<br/>&nbsp;&nbsp;- leftValueReference: ToggleOutputDIsplay.value<br/>&nbsp;&nbsp;&nbsp;&nbsp;operator: EqualTo<br/>&nbsp;&nbsp;&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;booleanValue: false<br/>&nbsp;&nbsp;- leftValueReference: ToggleOutputDIsplay.value<br/>&nbsp;&nbsp;&nbsp;&nbsp;operator: IsNull<br/>&nbsp;&nbsp;&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;booleanValue: true<br/>|
    |Label (input)|Data Table|
    |Selection Mode (input)|NO_SELECTION|
    |Min Row Selection (input)|numberValue: 0<br/>|
    |Table Data (input)|apex_objectOutput.repairSorLines|
    |Key Field (input)|complexValue: >-<br/>&nbsp;&nbsp;{dataType:Apex,objectType:AhaErlFlowOutputLine,fieldReferences:[outputReference],elementReference:apex_objectOutput.repairSorLines}<br/>complexValueType: ComplexObjectFieldDetails<br/>|
    |Max Row Selection (input)|numberValue: 0<br/>|
    |Columns (input)|[{"apiName":"sorCode","guid":"column-b2bd","editable":false,"hasCustomHeaderLabel":true,"customHeaderLabel":"SOR","wrapText":true,"order":0,"sortable":false,"label":"sorCode","type":"text"},{"apiName":"sorHeading","guid":"column-a8f4","editable":false,"hasCustomHeaderLabel":true,"customHeaderLabel":"Heading","wrapText":true,"order":1,"sortable":false,"label":"sorHeading","type":"text"},{"apiName":"repairLocation","guid":"column-c69f","editable":false,"hasCustomHeaderLabel":true,"customHeaderLabel":"Location","wrapText":true,"order":2,"sortable":false,"label":"repairLocation","type":"text"},{"apiName":"sorQuantity","guid":"column-1f87","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":3,"sortable":false,"label":"sorQuantity","type":"text"}]|
    |Column References (input)|complexValue: >-<br/>&nbsp;&nbsp;{dataType:Apex,objectType:AhaErlFlowOutputLine,fieldReferences:[sorCode,sorHeading,repairLocation,sorQuantity],elementReference:apex_objectOutput.repairSorLines}<br/>complexValueType: ComplexObjectFieldDetails<br/>|
    
    
    
    
    #### JSONOutput
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Field Text|<p><strong>JSON Output from Previous Screen:</strong></p><p>{!text_JSONOutput}<span class="ql-cursor">﻿</span></p>|
    |Field Type| Display Text|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    |Visibility Rule|conditionLogic: and<br/>conditions:<br/>&nbsp;&nbsp;leftValueReference: ToggleOutputDIsplay.value<br/>&nbsp;&nbsp;operator: EqualTo<br/>&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;booleanValue: true<br/>|
    
    
    
    
    ### No_Categories_Error
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Type|Screen|
    |Label|No Categories Error|
    |Allow Back|✅|
    |Allow Finish|✅|
    |Allow Pause|✅|
    |Show Footer|⬜|
    |Show Header|✅|
    
    
    #### noCategoriesText
    
    |<!-- -->|<!-- -->|
    |:---|:---|
    |Field Text|<p>No Categories have been set up yet, this example flow cannot be used. Go to <a href="/lightning/n/ERL_Preview" rel="noopener noreferrer" target="_blank">ERL Preview</a> to set up some data for ERL first.</p>|
    |Field Type| Display Text|
    |Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
    
    
    
    
    
    
    
    
    ___
    
    _Documentation generated from branch main by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_


# Easy Repair Locator (ERL) - Salesforce Open Source App
 
A simple graphical tool to allow a user to select a repair and provide the relevant Schedule of Rates (SOR) Code for use in repair logging systems. By default it's configured to be used for repairs, but it can be configured for any need that has a hierarchical structure.

## <a name="Contributors" id="Contributors"></a> Contributors
Thanks to the following people for their help in devleoping, supporting and promoting this product and generously sharing it with wider community.
- **Matthew McMahon** (Riverside)
- **Jonathan Pilkington** (Riverside)
- **Graham Weaver** (Riverside)

<br> 
<img width="219" height="226" alt="ERL1" src="https://github.com/user-attachments/assets/18c4eb02-341e-437f-9be5-c6920c36df8c" />
<br>
<br>

> **Installing this app?** See [AI-install-instructions.md](AI-install-instructions.md) for a step-by-step guide written from a real install run, including correct CLI commands and known issues. Recommended over the installation section below for AI installers.

# Table of Contents
1. [What It Does](#WhatItDoes)
2. [Prerequisites](#Prerequisites)
3. [Installation](#Installation)
   - [Clone the repo](#CloneTheRepo)
   - [Deploy to your Org](#DeployToOrg)
4. [Post-Deployment Configuration](#PostDeployConfig)
   - [Grant Permissions](#GrantPermissions)
   - [Validate on Test App](#ValidateOnTestApp)
   - [Create your own Repair Categories and Repairs](#CreateRepairCategoriedRepairs)
5. [Contributors](#Contributors)
6. [Documentation](#Documentation)

## <a name="WhatItDoes" id="WhatItDoes"></a> What It Does

1. In built editor with drag and drop functionality
2. Two modes of operation: standard and guided
   1. Standard can display multiple repair options for each repair problem
   2. Guided determines each problem is a single repair and only prompts the user for a location
3. Multiple levels of repair hierarchy
4. Includes in app Advice
5. Allows the addition of messages
6. Permission set based access for editing and viewing
7. Capable of using multiple repair profiles to restrict available repairs

***
## <a name="Prerequisites" id="Prerequisites"></a> Prerequisites
- Check that the **Salesforce CLI** (Command Line Interface) is installed. [Install guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)

```bash
sf --version
sf update
# Ensure CLI is authenticated to your org and set to default:
sf org login web --alias my-org-alias --set-default
```

***
## <a name="Installation" id="Installation"></a> Installation

### <a name="CloneTheRepo" id="CloneTheRepo"></a> 1. Clone the repo

```bash
git clone <repo-url>
cd uk-housing-erl-diagnostic
```
### <a name="DeployToOrg" id="DeployToOrg"></a> 2. Deploy to your org

Deploy in one simple step.

```bash
sf project deploy start --manifest manifest/package.xml --target-org <your-alias>
```

---

## <a name="PostDeployConfig" id="PostDeployConfig"></a> ⚙️ Post-Deployment Configuration

> Complete all steps below **in the target org** after the deploy command above succeeds.

### <a name="GrantPermissions" id="GrantPermissions"></a> 1. Grant Permissions

A permission set is need to be able to access the AHA-ERL tool.

1. Go to **Setup**
2. Go to your user record
3. Scroll down to the **Permission Set Assignment** section
4. Click the **Edit Assignments** button
5. Find the **ERL Full Access** permission set in the list on the left and click the **>** arrow
6. Click the **Save** button

### <a name="ValidateOnTestApp" id="ValidateOnTestApp"></a> 2. Validate on Test App

You can check the install has been successful by switching to the AHA-ERL Configuration App.

1. Click the **App Selector** (9 dots in the top left)
2. Search for ERL
3. Click **AHA-ERL Configuration** from the Apps list

You can create a small set of test data on using the **AHA-ERL Configuration** if there are no categories already configured. 

1. Click on the button **Generate Example Data**

This will create a couple of categories and sample repairs to demonstrate the capabilities of ERL.

### <a name="CreateRepairCategoriedRepairs" id="CreateRepairCategoriedRepairs"></a> 3. Create your own Repair Categories and Repairs

To be able to add new categories and repairs you need to switch to edit mode.

#### Add Category

1. Toggle the **Edit Mode** to on
2. Click the **Add Category**
3. If this category is going to be available for Guided users, check the **Is Guided** checkbox
4. Enter the **New Category Name**
5. The **Edit Mode Label** will be defaulted to the same as the **New Category Name** but this can be edited
6. For the **New Category Image (uses AhaErlIcons)** enter the path and name of the icon from AhaErlIcons in static resources. (e.g. KITCHENSANDSINKS/KITCHEN.jpg)
7. Click **Save**

#### Add Closeup

8. Click on the new **Kitchen** category
9. Click **Add Closeup**
10. If this category is going to be available for Guided users, check the **Is Guided** checkbox
11. Enter the **New Closeup Name**
12. The **Edit Mode Label** will be defaulted to the same as the **New Closeup Name** but this can be edited
13. For the **New Closeup Image (usesAhaErlImages)** enter the path and name of the image from the AhaErlImages in static resources. (e.g. KITCHENSANDSINKS/KITCHEN_CLOSEUP.jpg)
14. Click **Save**

#### Add Button

15. Click **Add Button**
16. If this category is going to be available for Guided users, check the **Is Guided** checkbox
17. Enter the **New Button Name**
18. The **Edit Mode Label** will be defaulted to the same as the **New Button Name** but this can be edited
19. Click **Save**
20. To position the button, click the Move button ✥
21. Click on the image where you want the button to be located. You can keep clicking around the image to position the button.
22. When happy with the location, click the save icon 💾

#### Add Item

23. Click **Add Item List**
24. If this category is going to be available for Guided users, check the **Is Guided** checkbox
25. Enter the **New Item List Name**
26. The **Edit Mode Label** will be defaulted to the same as the **New Item List Name** but this can be edited
27. Click **Save**
28. Click **Add SOR**
29. Find a SOR in the list and click the plus button ➕
30. Click **Save**
31. You have added a new category, problem and repair, so you can now turn off **Edit Mode**
32. This can now be tested by using the **AHA ERL Example Flow**

### 4. Add Advice

ERL has the ability to contain in app advice for the user. This can also be added from within the configurator but you will need to be in edit mode.

1. Toggle the **Edit Mode** to on
2. Traverse the repair hierarchy to the lowest level so you can see the closeup of the repair area, e.g. Plumbing -> Basins
3. Click **Add Advice**
4. Enter the advice that you want to display
5. Click **Save**
6. You can now turn off **Edit Mode**
7. Clicking on the **Repair Advice** button that has now appeared will show you the advice you entered

### 5. Add Messages

ERL has the ability to add messages that appear at the issue or item level. This can also be added from within the configurator but you will need to be in edit mode.

1. Toggle the **Edit Mode** to on
2. Traverse the repair hierarchy to the lowest level so you can see the closeup of the repair area, e.g. Plumbing -> Basins
3. Click on any existing button (or add your own as per the steps above)
4. Click **Add Message**
5. If this category is going to be available for Guided users, check the **Is Guided** checkbox
6. A **New Message Name** is defaulted but this can be updated
7. The **Edit Mode Label** is also defaulted to match the New Message Name but this can also be edited
8. Enter your message
9. Click **Save**

### 6. Add Profiles

Profiles allow you to choose what repairs are available and limit per profile. So, for example, you can have a profile that only includes Communal/Shared Space repairs and when implementing ERL in a flow, if you provide that profile in the config, only those repairs will be visible.
To create a profile, follow the steps below

1. Toggle the **Edit Mode** to on
2. Select the **Profiles** tab
3. Select the drop down arrow 🔽 on the Default row and select **Clone**
4. Enter a **New Profile Name**
5. Enter a **New Profile Description**
6. Click **Save**
7.  Select the drop down arrow 🔽 on the new profile row and select **View All Assigned SORs**
8.  You can now select which SOR codes are going to be available to this profile. You can select the **Show Unassigned Only** to show the list of SOR codes that are not assigned to this profile. This will automatically save as you select/unselect each SOR.

### 7. Add SORs

In order to use this successfully for repairs, (or any other purpose) SOR codes are needed. These are the actual items that will be used to generate the repair.
These need importing into the **AHA_ERL_Code__c** object

---

## <a name="Documentation" id="Documentation"></a> Documentation

[Read auto-generated documentation of the SFDX project](docs/index.md)

### Doc HTML Pages

To read the documentation as HTML pages, run the following code (you need [**Python**](https://www.python.org/downloads/) on your computer)

```python
pip install mkdocs-material mkdocs-exclude-search mdx_truly_sane_lists || python -m pip install mkdocs-material mkdocs-exclude-search mdx_truly_sane_lists || py -m pip install mkdocs-material mkdocs-exclude-search mdx_truly_sane_lists
mkdocs serve -v || python -m mkdocs serve -v || py -m mkdocs serve -v
```

To just generate HTML pages that you can host anywhere, run `mkdocs build -v || python -m mkdocs build -v || py -m mkdocs build -v`


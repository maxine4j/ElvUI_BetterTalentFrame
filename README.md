# ElvUI BetterTalentFrame

ElvUI BetterTalentFrame adds specialisation tabs much like the pre-Legion dual specialisation tabs. These tabs allow the player to view their non-active specialisation's talents at any time.

Other improvements include being able to switch specialisation on any tab of the talent frame and saving/loading custom talent profiles.

### Talent Profiles

Talent profiles allows you to save and apply talent configurations with a single click.
Profiles are saved per class/spec (i.e. all your feral druids will have access to the same profiles).
You still have to be in a city or inn (or have a talent change buff active) to be able to change and apply profiles, but simply managing your profiles can be done anywhere.

#### Creating a profile

1. Open the talents interface.
2. Configure your talent tree as you wish.
3. Click on the dropdown menu.
4. Click on the "Add a new profile" option.
5. Name your new profile.

#### Applying a profile

1. Make sure you are able to change talents.
2. Select your desired profile from the dropdown menu.
3. Click the "Apply" button.

#### Updating an existing profile

1. Make sure you are able to change talents.
2. Select your desired profile from the dropdown menu.
3. Click the "Save" button.

#### Applying a profile in a macro

##### Function:

    ARWICTP_ActivateProfile(profileIndex)
    
##### Example Macro:

    /equipset AoE
    /run ARWICTP_ActivateProfile(2)

#### Chat Commands

    -- activates talentprofile with ID <profileID>
    -- IDs starting with 1
    /talentprofiles activate <profileID>
    
    -- cycle through talentprofiles
    /talentprofiles next

    -- Info
    "/tp" is an alias for "/talentprofiles"

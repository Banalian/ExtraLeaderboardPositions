# ExtraLeaderboardPositions

Trackmania Next (2020) plugin that allows you to see the times of any positions in the leaderboard, as well as the hypothetical positions of any medals.

This can be used to see how far approximatly you are from getting a better trophy reward in a TOTD for example.

I have a few features planned for when I'll have more time to work on the plugin, but if you have any ideas for features, I'd be happy to hear them ! (you can use the issues or discord, in the OpenPlanet server)

Please open an issue if you see any trouble.

Openplanet link : [plugin](https://openplanet.dev/plugin/extraleaderboardpositions)

# Changelog

## 2.6.2
- Added support for the plugin [s314ke Medals](https://openplanet.dev/plugin/s314kemedals)
- Fixed an issue where the pb leaderboard entry would sometimes miss its data (color/icon etc...)

## 2.6.1
- Added an option to choose a custom color for the icon and text of each entry in the leaderboard.
- Added "support" for Platform (hides the plugin when in platform mode since there's no leaderboard).
- Added an option to disable the headers (name of the columns like Time, % etc...) in the leaderboard.
- Fix a bug where the plugin sometimes isn't able to get your PB in a map if you PBed without getting a new medal (unless you got a new PB after AT).
- Fix custom medals like Champion not having their correct color.
- Internal change to allow multiple custom medals to appear at the same time when using the external API.

## 2.6.0
- Big refactor for more customization for the entries! You can now individually change the icon, color icon and the text color of each entry! Please report any bug you might find with this new feature as it's a big change. Report via Github or Discord, with logs if there's any.
- Added a migration system to go from the old system to the new one. It should be automatic, but if you have any trouble, please report it too.

## 2.5.1
- Changed the order of the UI for the custom position settings. The + and - buttons are now on top of the list of custom positions instead of below, which was making it hard to add or remove multiple custom positions rapidly.
- Fixed a bug where reloading the plugin after emptying the custom positions would put custom positions back to their default values.

## 2.5.0
- Added support for the plugin [Warrior Medals](https://openplanet.dev/plugin/warriormedals) (Thanks a lot to Ezio for their PR!)

## 2.4.0
- Added support for the new Stunt mode
- Allowed users to have no custom position in the leaderboard (compared to needing at least one)
- Chore : API change for the strip code OP function

## 2.3.3
- Refactor/Upgrade of the early pb update : Now the default behavior, upgraded to correctly update (Huge thanks to zanaptak for their PR!!)
- Added an option to show the PB as either white, green or grey (Also thanks to zanaptak's PR)

## 2.3.2
- Added a setting to update the PB early (i.e. when you have a new pb, show it in the leaderboard even if the whole leaderboard isn't refreshed yet)
- Reverted the change allowing you to request specific positions between 10k and 100k, as this was an unintended change of the Nadeo API. (you can still see the accurate positions of your pb and medals if they are below 100k)
- Updated the loading icon to look like a small gif

## 2.3.1
- Added a setting to choose when to start shortening the position number if the setting is enabled
- Modify the maximum position you can request to 100k (from 10k) (Thanks to Nadeo !)
- Fixed a typo in the plugin's setting description

## 2.3.0
- Added a new setting to show the percentage view of the time (meaning, you can see the top%, for exemple, if you were top 100 on a map with 1000 players, you'd see 10%) (Thanks to Dayshine/tboby for the PR !)
- Fixed warnings because of deprecated constant BaseURL() (Thanks to NaN-inf for the PR !)

## 2.2.0
- Added Optional Dependency to SBVille Challenge medal plugin

## 2.1.1
- Added a new setting to show or hide the plugin's name
- Changed where the refresh text is displayed. Is it now an icon displayed on the top right of the window, next to the map name if it's enabled. You may hover the icon to see the "refreshing" text appear. A warning will also appear if the refresh failed.
- Fixed a bug where the time difference would not appear if two entry had the same position

## 2.1.0
- Added a new setting to shorten the position number if wanted (10k instead of 10000 for example)
- Added a new setting to show the number of players in the leaderboard on a map (only available with the external API)

## 2.0.1
- Fixed a bug where the plugin would crash if you left the map while the leaderboard was refreshing

## 2.0.0
Big rewrite of the plugin for more functionality !
- Rewrite of the plugin to hopefully have faster refreshing time in "normal" mode
- Added a mode that uses an external API to gather the leaderboard (this mode allows for faster refreshes, and for getting medals positions even if you pb is better for example)
    - This mode is Opt-in, and can be enabled in the settings
    - It might be disabled in the future depending on the API's availability
- Added Optional Dependency to Champion Medals
- Added a new setting to show the medals positions even if you have a better time (if you're using the external API mode)
- Added Icons to the settings tab and changed the orders
- Added the time it takes to refresh the leaderboard to the log, as well as the method used

## 1.6.2
- Changed windows flag to not focus on appearing window
- Plugin now won't display when in Royal mode

## 1.6.1
Internal change following OP Update
- Removed deprecated imports
- Remove warnings

## 1.6
Map name and author
- Add the possibility to have the map name and author displayed (this is off by default)
- Add a separator below the plugin's name (on by default, but can be disabled)

## 1.5.1
- Added a fix to stop trying to get the personal best after a few failed tries. it'll stop trying to get the leaderboard until the timer is up or a refresh is forced (via the buttons)

## 1.5
Medals positions
- Added medals position, telling you where that medal time would be in the leaderboard (to get an idea of how hard an AT is for example)

## 1.4.1
- Fixed a few typos (Thanks you D0mm4S for the help !)
- Added different display mode like hide when interface is hidden, or hide when driving

## 1.4
- Remade the menu to add a Hide/Show button and a force refresh button
- Added an option for a refresh button on the UI
- Fixed a bug linked to the leaderboard not refreshing correctly when playing new maps

## 1.3.3
- Hotfix 2 Electric boogaloo : Fixed the getter for the local pb and slightly improved the first hotfix

## 1.3.2
- Hotfix for new game update : Checks for permissions every 30 seconds if you don't have them yet

## 1.3.1
- Added and option to color the time difference (blue if negative, red otherwise)

## 1.3
More customization !
- Time difference : Show the time difference between a given time and all the other ones
- Refresh button : No need to wait to see the changes you made
- Internal refactor to have multiple files
- Removed perms in info.toml to use Permissions.as instead

## 1.2
Customization Update !
- Timer customization
- Positions customization
- Show pb or don't

## 1.1
- Added the personal best to the list
- Fixed different crash in different gamemodes
- Now refreshes every 5 minutes, or when a new pb is set, or on a new map
## 1.0
Initial Upload :

- Signed plugin
- Initial feature like the positions and times

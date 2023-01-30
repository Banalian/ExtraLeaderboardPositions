# ExtraLeaderboardPositions

Trackmania Next (2020) plugin that allows you to see the times of more key positions (1st, 10th, 100th, 1000th and 10000th place times)

This can be used to see how far approximatly you are from getting a better trophy reward in a TOTD for example.

I have a few features planned for when I'll have more time to work on the plugin, but if you have any ideas for features, I'd be happy to hear them ! (you can use the issues or discord, in the OpenPlanet server)

Please open an issue if you see any trouble.

Openplanet link : [plugin](https://openplanet.dev/plugin/extraleaderboardpositions)

# Changelog
## 2.0.0
Big rewrite of the plugin for more functionality !
- Rewrite of the plugin to hopefully have faster refreshings in "normal" mode
- Added a mode that uses an external API to gather the leaderboard (this mode allows for faster refreshes, and for getting medals positions even if you pb is better for example)
    - This mode is Opt-in, and can be enabled in the settings
    - It might be disabled in the future depending on the API's availability

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

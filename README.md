# Simulation Scoring

<img src="SimScoringIcon.png" width=48 height=48></img> 

This repo contains the **Simulation Scoring** tool. Shown below is a brief description of the contents. 

| File                              | Description                                       |
|-----------------------------------|---------------------------------------------------| 
| SimScoringConfig.xml              | Configuration for plugin (auto generated)         |
| SimScoringGui.html                | Gui for plugin (auto generated)                   |
| SimScoringIcon.png                | Icon for plugin                                   |
| app.min.js                        | Script to interactively manipulate Gui.html       |
| app.css                           | Custom style sheet for Gui.html                   |
| Gui/overrides.yaml                | Configuration to override widget properties       |
| Gui/layout.html                   | Layout for organizing widgets in Gui.html         |
| Supporting_Macros\\SimScoring.yxmc | Macro backend                                     |

### Installation

1. Download https://github.com/alteryx/SimScoring/archive/master.zip.
2. Rename `.zip` to `.yxi`.
3. Open in Alteryx to complete installation.

### Development

Clone this repo using RStudio or the command line. Use branches to work on features and bug fixes. Commit often. Send a PR to the upstream repo to merge your changes back in. Make sure to sync your clone with the upstream repo before sending a PR, so that merge conflicts are avoided.

The `source` files that will be modified directly include

1. Supporting_Macros\SimScoring.yxmc (backend)
2. Gui/overrides.yaml                (gui)
3. Gui/layout.html                   (gui)
4. app.min.js                        (gui)
5. app.css                           (gui)

Whenever you manipulate one of these source files, you would need to run two functions from the `AlteryxRhelper` package to update everything.

1. `createPluginFromMacro(".")` will auto generate Config.xml and Gui.html files.
2. `updateHtmlPlugin(".")` will install the plugin in the `Alteryx` directory.

Run both these functions to ensure that the changes you have made can be previewed in Alteryx.



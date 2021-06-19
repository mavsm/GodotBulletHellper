# GodotBulletHellper
Plugin for the Godot Engine to help in making bullet hell/danmaku style attack patterns.

## Installing 
Download the repository, then copy its 'addons' folder into your Godot project. Enable the plugin in your project's settings and you should be ready to go.

## Using the Pattern Maker
Inside the plugin's folder you'll find the PatternMaker.tscn file. Using it you should be able to build and export patterns using the scene's tools. Keep in mind that hovering your mouse over property names gives tips on their use!

## General Usages

### Bullets
The bullets used by the plugin come in 3 types, Big, Small and Simple. To add other types of bullets, simply add them to the plugin's BulletHellper/BasicBullets/ folder and make sure their scene's name ends with the suffix 'Bullet' and they implement a Vector2 'direction' in their script.

### Collision
All of the plugin's internal objects (bullets, prop bomb and prop player) use user-calculated collision (this was used as opposed to other methods due to being more efficient in testing with high bullet numbers). To have the bullets collide with a simple player node, register it the singleton BHPatternManager with the function register_bullet_target(node) and set BHPatternManager's target_radius and target_graze_radius.

<br/>

#### Thanks!
If you have any questions just send em, Im still figuring out how to organize this project.

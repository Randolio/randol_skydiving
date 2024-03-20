## Randolio: Skydiving

**ESX/QB/ND supported with bridge.**

This was rewritten on 20/03/2024 from my god old awful code. This is now just a solo sky diving resource which I've rewritten to use the synchronized scenes, cams and sounds from the GTA Online Junk Energy jumps.

* Create multiple jump locations in the server config with set prices for each spot.
* All jumps have a busy state set so players can't take the same jump at the same time.
* Customizable parachute style selector (Only sets when you deploy) and smoke trail color using ox lib, before proceeding to the jump.
* Supports qb/ox target or world interact script which can be found here: https://github.com/darktrovx/interact

**Notes**:

* The helicopter and pilot are not networked because they simply don't need to be for this situation.
* You will auto jump after 30 seconds if you do not press SPACEBAR to manually jump.
* To make your smoke trail appear you must deploy your parachute and hold your X key.
* There is no group support.

**Showcase**: https://streamable.com/j1ukh2

## Requirements

* [ox_lib](https://github.com/overextended/ox_lib/releases/)

**I do not care for your ideas or suggestions. I had my idea, I wrote it and released it for free. It functions as I wanted it to and if you can’t respect that, don’t use it. You're free to use this in your server and make your own personal changes but you're not allowed to redistribute.**
# qbx_idcard

Identity cards, licenses and badges for Qbox, with an in-game card designer.

![The card designer](docs/media/designer-overview.png)

<p align="center">
<img width="49%" src="docs/media/viewer-card.png">
<img width="49%" src="docs/media/viewer-badge.png">
</p>

## Features
* Use a card item to hold it in your hand and show it to the closest player, or yourself if nobody is near
* Badges are held as a badge prop and can be limited to jobs, so only police can flash a police badge
* `/idcards` opens the card designer for admins: lay out text, data fields, the mugshot, images and shapes per item
* Designs are stored in the database and apply instantly, no restart needed
* The UI follows your ox_lib theme through the `ox:primaryColor` and `ox:primaryShade` convars
* A mugshot is taken on first use and saved in the item metadata, optionally uploaded to a CDN

## Dependencies
* [ox_lib](https://github.com/overextended/ox_lib)
* [oxmysql](https://github.com/overextended/oxmysql)
* [qbx_core](https://github.com/Qbox-project/qbx_core)
* [ox_inventory](https://github.com/overextended/ox_inventory)
* [MugShotBase64](https://github.com/BaziForYou/MugShotBase64)

The `qbx_idcard_templates` table is created automatically on start.

## Card items (ox_inventory)
Add the following to your `ox_inventory/data/items.lua`. Any other item can be turned into a card from the designer.

```lua
['id_card'] = {
    label = 'Identification Card',
},

['driver_license'] = {
    label = 'Drivers License',
},

['weaponlicense'] = {
    label = 'Weapon License',
},

['lawyerpass'] = {
    label = 'Lawyer Pass',
},

['police_badge'] = {
    label = 'Police Badge',
},
```

## Designer
![A custom weapon permit built from a blank card](docs/media/designer-custom-card.png)

* `/idcards` (`group.admin` by default, see `config/shared.lua`) opens the designer
* Cards listed in `config/shared.lua` show their default design until you save a custom one, **Reset** returns to the default
* **New card** turns any inventory item into a card, starting from the ID card, badge wallet or a blank preset
* Set the type to **Badge** to hold the badge prop instead of the card prop, and fill in **Jobs** to limit who can show it
* **Preview in hand** plays the hold animation so you can tune the prop and its custom hand position
* **Give to me** issues the card to yourself for testing
* Shortcuts: `Ctrl+Z` / `Ctrl+Y` undo and redo, `Ctrl+D` duplicate, `Delete` remove, arrow keys nudge (`Shift` for 10px), `Ctrl+S` save. Hold `Shift` while dragging to skip snapping.

Images can be `https://` links or files placed in `web/public` (for example `badges/examplebadge.png`), which requires rebuilding the UI.

The full walkthrough is in [docs/designer.md](docs/designer.md), badges in [docs/badges.md](docs/badges.md).

## Mugshot uploads
Mugshots are stored in the item metadata as base64 by default. Set `imageUpload` in `config/server.lua` with an API key to upload them to a CDN instead, so the metadata only holds the image url.

* Providers: `qbox`, `fivemanage`, `fivemerr` or `custom` (your own `url`, form `field` and `responsePath` to the url in the json response)
* Cards that already hold a base64 mugshot are uploaded and switched to the url the next time they are used
* If an upload fails the base64 mugshot is kept, so cards keep working

See [docs/cdn.md](docs/cdn.md) for the details.

## Commands
* `/idcards` open the card designer
* `/givecard [id] [item]` issue a card to a player, filled in with their character data

## Exports
```lua
-- Give one or more cards with the player's character data as metadata
exports.qbx_idcard:CreateMetaLicense(source, 'id_card')
exports.qbx_idcard:CreateMetaLicense(source, { 'id_card', 'driver_license' })

-- Build the metadata without giving the item, e.g. for starter items
local metadata = exports.qbx_idcard:GetMetaLicense(source, 'id_card')
```

## Building the UI
The UI is a Svelte app in `web/`. The built files in `web/build` are committed, rebuild after changing anything in `web/src`:

```sh
cd web
bun install
bun run build
```

## License
[GNU General Public License v3.0](https://choosealicense.com/licenses/gpl-3.0/)

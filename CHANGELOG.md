# Changelog

## [0.4.15] - TBA

- added Email on Acid rule (thanks @m-schmitt)
- added Aislelabs rule
- improved generic rule for Sendinblue
- improve Zoho rule (thanks Robert R.)

## [0.4.14] - 2021-10-25

- added OutMaster rule (thanks James M.)
- improved generic rules for Qualtrics and Amazon SES (thanks Robert R.)
- fixed generic tracker rule falsely identifying spacers as trackers in some cases

## [0.4.13] - 2021-10-13

- #141 added The Atlantic daily rule (thanks @dcquad and Damon S.)
- added Maropost and a DotDigital custom domain (thanks Damon S.)
- #139 added Branch rule (thanks @austinhuang0131)
- #137 added Newegg rule (thanks @m-schmitt)
- added Smore rule (thanks Robert R.)
- added Blackbaud, Higher Logic rules (thanks David K.)
- added Qualtrics rule (thanks Bill S.)

## [0.3.29] - 2021-04-06

- 🆕 #102 fixed broken text and links in some emails by limiting blocking to img tags (thanks @ybbond)

## [0.3.3] - 2020-12-16

- Added native support for Apple Silicon #3 (thanks @colamixer)

## [0.3.2] - 2020-12-16

- Official support for macOS 11.1 (issue #3)

## [0.3.0] - 2020-08-24

- Shrunken installer size.
- Installations via a private Brew Cask now available.
- Signed and notarized.

## [0.2.9] - 2020-08-09

- Added localization text for German and French
- Switched to a grey icon for the "probable" tracker case.
- Improved UI for RTL users.

## [0.2.1] - 2020-07-24

- Added a small button in the header to indicate the number of blocked tracker elements (🛑 2). Tapping it the button will reveal which services were blocked.

## [0.1.2] - 2020-07-11

- added filters for Amazon SES, GitHub, Wix
- fixed filters for Tinyletter, SendGrid, Mailgun, Hubspot and Active Campaign
- added a filter for generic 1x1 `<img>`s (getting some false positives on it removing some cosmetic padding/spacers that some mailing templates use but it removes quite a few unknown trackers)

## [0.1] - 2020-07-05

- Simple blocking of trackers. No UI.
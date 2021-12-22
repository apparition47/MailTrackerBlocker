# Changelog

## [0.5.7] - TBA

- improve 1&1 rule (thanks James M.)
- #159 improve Selligent and HubSpot rules, add Tripolis rule (thanks @Jee-Bee)
- improve Infusion Software, add G-Lock Analytics, Ongage (thanks Robert R.)

## [0.5.6] - 2021-12-18

- improve Higher Logic, add Mailshake rules (thanks James M.)
- improve Salesforce rule (thanks Steve H.)
- #158 add Cyberimpact, Veribase (thanks @austinhuang0131)
- improve YouTube rule (thanks Robert R.)

## [0.5.5] - 2021-12-08

- #156 support Mail in macOS 12.1 (thanks @ackerthehacker2, @berkue)
- #146 exception for FedEx and Apple Pay spacers (thanks James M., @m-schmitt)
- #149, #146, #135 add Paved rule (thanks @m-schmitt)
- #155 add Telstra rule (thanks @oneofthedamons)

## [0.5.4] - 2021-12-05

- #154 added Paystone, Ashby rules (thanks @austinhuang0131)
- #153 added Liveclicker & eGain, improved Zeta Global, Customer.io, Granicus rules (thanks @m-schmitt)
- improved Zoho Campaigns rule, added YouTube
- added Benchmark Email, Epsilon (thanks James M.)
- more spacers identified as false positives (thanks James M.)
- added Mapp rule (thanks Robert R.)
- fixed SMTP.com rule
- renamed Mailchimp to Intuit

## [0.5.3] - 2021-11-28

- improved Meta/Facebook rule, added activecore rule
- #151 added Envoke rule (thanks @austinhuang0131)
- #152 improved Oracle rule (thanks @m-schmitt)
- improved ActiveCampaign, AT&T, Epsilon, MailJet rules (thanks James M.)
- added AutoAlert, marked Outlook OWA attachments as false positives (thanks Robert R.)
- added Hyper Hyper (thanks @oneofthedamons)

## [0.5.2] - 2021-11-18

- added Mailcampaigns, Rabobank (thanks @Jee-Bee)
- #150 added rule for Blackbaud, improved Optimove and Maropost rules (thanks @oneofthedamons)
- added 1&1, Salesforce rules (thanks James M.)
- #149 added Yardi rule (thanks @m-schmitt)
- added SMTP.com rule (thanks Robert R.)
- added Rakuten Securities rule
- added Indeed rule

## [0.5.1] - 2021-11-07

- added Oracle Bronto rule (thanks @oneofthedamons)
- #146 added US Bancorp (thanks @m-schmitt)
- #148 added Staples rule, improved Litmus CSS rule, fixed Optimove rule (thanks @m-schmitt)
- added Doorkeeper header logo rule

## [0.5.0] - 2021-10-30

- #145 allow usage on macOS 12
- added Email on Acid rule (thanks @m-schmitt)
- added Aislelabs rule
- added Splio rule
- improved generic rule for Sendinblue
- improve Zoho rule (thanks Robert R.)
- block CSS trackers

## [0.4.14] - 2021-10-25

- added OutMaster rule (thanks James M.)
- improved generic rules for Qualtrics and Amazon SES (thanks Robert R.)
- fixed generic tracker rule falsely identifying spacers as trackers in some cases

## [0.4.13] - 2021-10-13

- #141 added The Atlantic daily rule (thanks @dcquad and @oneofthedamons)
- added Maropost and a DotDigital custom domain (thanks @oneofthedamons)
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
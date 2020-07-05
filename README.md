# MailTrackerBlocker

MailTrackerBlocker is a plugin for Apple Mail on macOS to block trackers and spy pixels. [Inspired by Hey](https://twitter.com/dhh/status/1253389224516005889).

![](https://user-images.githubusercontent.com/3298414/86532790-795c7480-bf07-11ea-9939-e82b12b04c3e.png)

## Prerequisites

Only tested on Apple Mail 13.4 on macOS 10.15 Catalina.

## Installation

#### A. Makefile
```bash
git clone https://github.com/apparition47/MailTrackerBlocker.git
cd MailTrackerBlocker
make
```

#### B. Xcode

1. Give XCode `Full Disk Access` from `System Preferences > Security & Privacy > Privacy > Full Disk Access` and add XCode.
     * Need this because the plugin needs to be installed into the Mail Apps bundles at `~/Library/Mail/Bundles`.
2. Open the Xcode project in xcode, hit build.
3. In Xcode, open `Preferences > General > Manage Plug-ins... > check "MailTrackerBlocker.mailbundle" > Apply and Restart Mail`

#### C. Binary

1. Goto https://github.com/apparition47/MailTrackerBlocker/releases
2. Download then open the `.pkg` to install.


## Credits

* Mail.app hooking from [GPGMail](https://github.com/GPGTools/GPGMail)
* [Tracker blocking list from @dhh](https://gist.github.com/dhh/360f4dc7ddbce786f8e82b97cdad9d20)
# MailTrackerBlocker

MailTrackerBlocker is a plugin (i.e. mailbundle) for Apple Mail on macOS to block trackers and spy pixels. [Inspired by Hey](https://twitter.com/dhh/status/1253389224516005889).

![](https://user-images.githubusercontent.com/3298414/86532790-795c7480-bf07-11ea-9939-e82b12b04c3e.png)

This is accomplished by zeroing out bad known URL patterns which should catch the majority of trackers:

```diff
<img width="0" height="0" class="mailtrack-img" alt="" style="display:flex" src=
-"https://mailtrack.io/trace/mail/0eabccbe98c98e9b8e9a8b89eab89ce9ab89e8bc.png?u=1234567"
+"https://localhost/mail/0eabccbe98c98e9b8e9a8b89eab89ce9ab89e8bc.png?u=1234567"
>
```


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
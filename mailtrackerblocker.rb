cask "mailtrackerblocker" do
  version "0.3.0"
  sha256 "a1f8d3d00884b0698395778d328ffa8cc005af49b1288916929e707a046becd2"
  
  url "https://github.com/apparition47/MailTrackerBlocker/releases/download/#{version}/MailTrackerBlocker.pkg"
  appcast "https://github.com/apparition47/MailTrackerBlocker/releases.atom"
  name "MailTrackerBlocker"
  desc "An email tracker, read receipt and spy pixel blocker plugin for macOS Apple Mail."

  homepage "https://apparition47.github.io/MailTrackerBlocker/"
  depends_on macos: ">= :el_capitan"
  pkg 'MailTrackerBlocker.pkg'
  uninstall pkgutil: "com.onefatgiraffe.mailtrackerblocker", 
  			delete: "/Library/Mail/Bundles/MailTrackerBlocker.mailbundle", 
  			signal: ["TERM", "com.apple.mail"]

  def caveats
    <<~EOS
      ℹ️  To enable and use:
      
      1. Open Mail, goto Preferences > General > Manage Plug-ins... > 
      check "MailTrackerBlocker.mailbundle" > Apply and Restart Mail.
      2. Tap on the ⓧ  button to find out what was blocked.

      ⚠️  Note:
	  
      Disabling "load remote content in messages" 
      with MailTrackerBlocker enabled is redundant; 
      enable both for the best experience.
    EOS
  end
end
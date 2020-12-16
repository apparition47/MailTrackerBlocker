cask "mailtrackerblocker" do
  version "0.3.3"
  sha256 "7203c5dc09dde858e08c28baa090ef5853f8167f20c13093f89fd22057f20730"
  
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
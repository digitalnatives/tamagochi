chrome.app.runtime.onLaunched.addListener(function(launchData) {
  chrome.commands.onCommand.addListener(function(command) {
    chrome.app.window.get('fileWin').show()
  });
  chrome.app.window.create('index.html', {
    id:"fileWin",
    frame: 'none',
    maxWidth: 310,
    maxHeight: 360,
    singleton: true
    }, function(win) {
      win.width
      win.contentWindow.launchData = launchData;
    });
});

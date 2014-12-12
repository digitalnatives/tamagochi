chrome.app.runtime.onLaunched.addListener(function(launchData) {
  chrome.app.window.create('index.html', {
    id:"fileWin",
    frame: 'none',
    maxWidth: 310,
    maxHeight: 370,
    singleton: true
    }, function(win) {
      win.width
      win.contentWindow.launchData = launchData;
    });
});

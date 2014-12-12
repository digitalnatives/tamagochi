chrome.app.runtime.onLaunched.addListener(function(launchData) {
  chrome.app.window.create('index.html', {
  	id:"fileWin",
  	minWidth: 310,
  	minHeight: 360,
  	frame: 'none',
  	singleton: true
  	//alphaEnabled: true
  	}, function(win) {
  		win.width
	    win.contentWindow.launchData = launchData;
	  });
});

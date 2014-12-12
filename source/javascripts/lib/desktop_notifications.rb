# Desktop Notifications
module DesktopNotifications
  # Shows a notification for with the given message
  # @param message [String] The message
  def self.notify(message)
    update do
      %x{
        noty = new Notification('Your little friend', { body: #{message}, icon: 'http://webneko.net/white/still.gif' })
        noty.onclick = function () {
          chrome.app.window.get('fileWin').show()
        }
      }
    end
  end

  private

  # Requests permissions for notificatons
  def self.update
    return yield if `#{native}.permission` == 'granted'
    `#{native}.requestPermission(function(){
      if(#{native}.permission == 'granted'){
        #{yield}
      }
    })`
  end

  # Returns the native Notifications obeject
  def self.native
    `window.Notification || window.webkitNotification || window.mozNotification`
  end
end

package io.snippeter.jetbrains

import com.intellij.notification.NotificationGroupManager
import com.intellij.notification.NotificationType
import com.intellij.openapi.project.Project

/**
 * Convenience wrappers around the "Snippeter" notification group so actions can
 * surface balloons without repeating the lookup. The group is declared in
 * plugin.xml so balloons are styled and logged consistently.
 */
object Notifications {

    private const val GROUP_ID = "Snippeter"

    fun info(project: Project?, message: String, title: String = "Snippeter") {
        notify(project, title, message, NotificationType.INFORMATION)
    }

    fun error(project: Project?, message: String, title: String = "Snippeter") {
        notify(project, title, message, NotificationType.ERROR)
    }

    private fun notify(project: Project?, title: String, message: String, type: NotificationType) {
        NotificationGroupManager.getInstance()
            .getNotificationGroup(GROUP_ID)
            .createNotification(title, message, type)
            .notify(project)
    }
}

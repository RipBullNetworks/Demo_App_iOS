//
//  Constants.h
//  eRTCApp
//
//  Created by Rakesh Palotra on 05/01/19.
//  Copyright © 2019 Ripbull Network. All rights reserved.
//

#ifndef Constants_h
#define Constants_h
#define DidRecievedMessageNotification @"didRecievedMessageNotification"
#define DidRecievedTypingStatusNotification @"didRecievedTypingStatusNotification"
#define DidRecievedMessageReadStatusNotification @"didRecievedMessageReadStatusNotification"
#define ContactDBUpdatedNotification @"contactDBUpdatedNotification"
#define DidRecievedAvailabilityStatusNotification @"didRecievedAvailabilityStatusNotification"
#define DidUpdateUserBlockStatusNotification @"didUpdateUserBlockStatusNotification"
#define DidGetChatSettingNotification @"didGetChatSettingNotification"
#define DeleteModerationMessage @"deleteModerationMessage"
#define DidUpdateOtherUserProfile @"didUpdateOtherUserProfile"

#define kGroupCreatedNotification @"createGroupSuccessfully"
#define kGroupUpdateSuccessfully @"groupUpdateSuccessfully"
#define DidReceivedGroupEvent @"groupEventReceived"

#define RefreshRecentChatList @"RefreshRecentChatList"

#define UpdatChatWindowNotification @"UpdatChatWindowNotification"
#define DidRecievedReactionNotification @"didRecievedReactionNotification"
#define DidUpdateChatNotification @"didUpdateChatNotification"
#define DidDeleteChatMessageNotification @"didDeleteChatMessageNotification"
#define UpdateGroupProfileSuccessfully @"updateGroupProfileSuccessfully"
#define UpdateIndicators @"updateIndicators"
#define UpdateInternetStatus @"updateInternetStatus"
#define ActionReceivedonVideoAndImage @"actionReceivedonVideoAndImage"
#define UpdatePrivacyKey @"updatePrivacyKey"
#define ChatReportSuccessfully @"chatReportSuccessfully"
#define JoinChannelSuccess @"joinChannelSuccess"
#define JoinChanneladdMoreSuccess @"joinChannelAddMoreSuccess"
#define DidReceveNameAndDescription @"didReceveNameAndDescription"
#define DidSendInvitationMessage @"didSendInvitationMessage"
#define DidUpdateChannelStatus @"didUpdateChannelStatus"
#define DidopenAnnounceMentpopup @"didopenAnnounceMentpopup"
#define DidReceveEventList @"didReceveEventList"
#define DidReceveEventStarFavouriteMessage @"didReceveEventStarFavouriteMessage"
#define UpdateUserProfileSuccessfully @"updateUserProfileSuccessfully"
#define DidGetChatAnnounceMentNotification @"didGetChatAnnounceMentNotification"
#define DidGetChatReportedIdUpdated @"didGetChatReportedIdUpdated"
#define DidRefreshAnnouncementpopup @"didRefreshAnnouncementpopup"
#define DidUpdateGlobalNotificationSetting @"didUpdateGlobalNotificationSetting"
#define DidupdateProfileAndStatus @"didupdateProfileAndStatus"

/* Messages */
#define NO_Network @"No internet connection."
#define manageNotificationSuccess @"Manage notification updated successfully"


#define APIKEY @"edu6qgwsjx440vld6436p937kdfiznm8"//@"edu6qgwsjx440vld6436p937kdfiznm8" //@"b3ox9unlagk9x2c51nsnc03g31ebfzuy"

#define Key_Success @"success"
#define Key_Result @"result"
#define Key_Message @"msg"
#define Key_Name @"name"
#define Key_Number @"numbers"
#define Key_Email @"emails"
#define IsLoggedIn @"isLoggedIn"
#define IsRestoration @"isRestoration"
#define RestorationAvailability @"restorationAvailability"
/* User Parsing key */
#define User_ID @"userId"
#define User_LoginTimeStamp @"loginTimeStamp"
#define App_User_ID @"appUserId"
#define User_Name @"name"
#define User_ProfileStatus @"profileStatus"
#define User_ProfileStatus @"profileStatus"
#define User_ProfilePic @"profilePic"
#define User_ProfilePic_Thumb @"profilePicThumb"
#define Thumbnail @"thumbnail"
#define User_eRTCUserId @"eRTCUserId"
#define JoinedAtDate @"joinedAtDate"
#define TenantID @"tenantId"
#define ThreadID @"threadId"
#define Start_Thread @"startThread"
#define ReplyMsgConfigStatus @"replyMsgConfigstatus"
#define ReplyMsgConfig @"replyMsgConfig"
#define ParentID @"parentId"
#define ParentMessageID @"parentMessageID"
#define UnReadMessageCount @"unReadMessageCount"
#define customData @"customData"
#define ChannelKey @"channelKey"
#define Reason @"reason"
#define MessageId @"messageId"
#define Category @"category"
#define Status @"status"
#define Limit @"limit"
#define Skip @"skip"
#define TenantAdminStatus @"tenantAdminStatus"
#define ReporterERTCUser @"reporterERTCUser"
#define CreatedAt @"createdAt"
#define TargetAppUserId @"targetAppUserId"
#define Key_chats @"chats"
#define Key_video @"video"
#define Freeze @"freeze"
#define Key_image @"image"
#define KeydeviceId @"deviceId"
#define keyEvent @"event"
#define ThreadType @"threadType"
#define Thread_msg @"thread"
#define Thread_replies @"replies"
#define Thread_NumberOfReplies @"numOfReplies"
#define Thread_message @"message"
#define configDomainFilter @"domainFilter"
#define configprofanityEnable @"profanityEnable"




//customData,,thread
#define AvailabilityStatus @"availabilityStatus"
#define BlockedStatus @"blockedStatus"
#define ProfilePicChanged @"profilePicChanged"
#define Key_frozen @"This channel is currently frozen, and you are unable to actions ."
#define Key_Freeze @"freeze"



#define Key_ChatUsers @"chatUsers"
#define Group_description @"description"
#define Group_Name @"name"
#define ParticipantsCount @"participantsCount"
#define Group_Type @"groupType"
#define Group_Participants @"participants"//participants
#define Group_GroupId @"groupId"
#define Action @"action"
#define Group_CreatorId @"creatorId"
#define Joined_Channel @"joined"
#define Enabled @"enabled"
#define Key_user @"user"
//channelKey

/* TableViewCell Identifier */
#define RecentChatCellIdentifier @"RecentChatTableViewCell"
#define UserContactsCellIdentifier @"UserContactsCell"
#define UserProfileCellIdentifier @"UserProfileCell"
#define MyProfileCellIdentifier @"myProfileCell"
#define MyReportsCellIdentifier @"tblReportCell"
#define MediaModerationCell @"MediaModerationCell"
#define TblSearchListCell @"tblSearchListCell"
#define DraftsTblCell @"DraftsTableCell"
#define StarredfavMessageCell @"StarredMessageCell"
#define RecentSearchWithCell @"RecentSearchCell"
#define ClearSearchrecentHistoryCell @"ClearSearchHistoryCell"
#define ArParticipants @"arParticipants"


/* Chat */
#define SendereRTCUserId @"sendereRTCUserId"
#define RecipientAppUserId @"recipientAppUserId"
#define RecepienteRTCUserId @"recipienteRTCUserId"
#define Update_UserProfile @"/updateUser"
#define Message @"message"
#define MsgType @"msgType"
#define FilePath @"path"
#define GifyFileName @"gify"
#define TextType @"text"
#define AudioFileName @"audio"
#define Image @"image"
#define LocalFilePath @"localFilePath"
#define ContactType @"contact"
#define LocationType @"location"
#define Numbers @"numbers"
#define Number @"number"
#define Latitude @"latitude"
#define Longitude @"longitude"
#define MsgUniqueId @"msgUniqueId"
#define IsFavourite @"isFavourite"
#define IsEdited @"isEdited"
#define IsForwarded @"isForwarded"
#define IsDeletedMSG @"isDeletedMsg"//follow sender
#define EmojiCode @"emojiCode"
#define Follow_Message @"follow"
#define Chat_ReportId @"chatReportId"
#define Chat_Sender @"sender"
#define MediaFileName @"mediaFileName"
#define ChatReportAction @"action" //reportConsidered
#define ReportedIgnored @"reportIgnored"
#define ChatServerBaseurl @"chatServerBaseurl"
#define ReportConsidered @"reportConsidered"
#define ProductionEnable @"productionEnable"
#define BaseUrlVersion @"v1/"





#define TypingStatusEvent @"typingStatusEvent"
#define MsgStatusEvent @"msgStatusEvent"
#define MsgDeliveredStatus @"delivered"
#define Login_Type @"loginType"
#define AvailabilityStatus @"availabilityStatus"
#define NotificationSettings @"notificationSettings"
#define IsStarred @"isStarred"
#define Istrue @"true"
#define IsFalse @"false"
#define Chat @"chat"
#define typeMedia @"media"
#define AppUserIds @"appUserIds"

#define AvailabilityuserId @"eRTCUserId"
#define Key_EventList @"eventList"
#define Key_EventData @"eventData"
//eventList

//QA
#define imageBaseUrl @"https://socket-qa.ripbullertc.com/v1/"



//Stagging
//#define imageBaseUrl @"https://socket-stage.ripbullertc.com/v1/"



//eRTCUserId ;//isStarred

//Your account got deactivated. Please contact your administrator
#define Away @"away"
#define Invisible @"invisible"
#define Online @"online"
#define Dnd @"dnd"
#define Offline @"offline"
#define Block_Status @"unblocked"
#define Blocked @"blocked"

#define Parent_Msg @"parentMsg"
#define ReplyThreadFeatureData @"replyThreadFeatureData"


/* Notification Type */
#define All_Message @"all"
#define Mention_Message @"mentions"
#define Nothing_Message @"none"
#define Nothing_Always @"Always"
#define Manage_OneDay @"24 hours"
#define Manage_threeday @"72 hours"
#define Manage_oneWeek @"1 week"
#define Manage_twoWeek @"2 week"
#define Manage_oneMonth @"1 month"
#define Manage_Allow_all @"Allow all"
#define Manage_Mentions_only @"Mentions only"
#define Manage_allowFrom @"allowFrom"
#define Manage_validTill @"validTill"
#define Manage_validTillDisplayValue @"validTillDisplayValue"



// stops seeing the "typing" indicator //@"1 week"//@"allowFrom"validTillDisplayValue/validTill
#define TypingTimeout 3.0

#define EditedString @" (edited)"
#define ForwardedString @" Forwarded"
#endif /* Constants_h */



//App Messages//
#define messageLargeVideoFile @"Video size is too large. You can’t upload video more than 25 MB"
#define messageLargeAudioFile @"Audio size is too large. You can’t upload audio more than 25 MB"
#define messageLargeImageFile @"Image size is too large. You can’t upload Image more than 25 MB"
#define msgLeaveGroup @"You will need to rejoin the channel in order to participate in the conversation."
#define msgContinueGroup @"There are no other admins of this channel, so you will need to choose a replacement admin before you can successfully leave the channel."
#define msgClearChatHistory @"The conversation will only be cleared for you."
#define FollowThreadMessage @"Thread followed successfully."
#define ThreadUnFollowMessage @"Thread Unfollowed successfully."
#define ChatMsgClearSuccess @"Chat History Clear Successfully."
#define msg_Delete_conversation @"All messages and files within conversation will be deleted."
#define msg_Reported_conversation @"Message will no longer appear in chat, and sender will be notified of its removal."
#define Allow_Reported_conversation @"Message will stay in chat, and reporter of message will be informed of decision."
#define DissapearingMsg @"You turned on dissapearing message. New messages will disappear from this chat after 7 days. Tap to edit."
#define DomainFilterMsg @"The message or media you are attempting to share contains a link from a restricted domain and cannot be sent."
#define ProfanityFilterMsg @"The message you are attempting to share contains language that is restricted from being used in this chat."
#define Block_Msg @"They will not be able to contact you until you unblock them."
#define GlobalSearch_msg @"This feature is not active in your project. Please contact your administrator for details."
#define Block_MsgBlocked @"Are you sure you want to block this user?"
#define Join_Channel @"Please Join Channel ."
#define ReasonMessage @"Please Enter Reasoan"
#define EnterCategory @"Please Select Category"

#define Notifcation_schedule @"You already have a custom notifcation schedule set. Select View to see remaining schedule, or Delete to end it."

#define Private @"private"
#define Public @"public"
#define Save @"Save"
#define Next @"Next"
#define Delete_conversation @"Delete conversation?"
#define Clear_Chat_History @"Clear Chat History?"
#define Delete_message @"Delete message?"
#define Allow_message @"Allow message?"
#define Block_user @"Block User?"
#define UpdateChannelStatus @"channelStatus"
#define LeaveChannel @"leaveChannel"
#define DomainFilter @"domainFilter"
#define ProfanityFilter @"profanityFilter"
#define Details @"details"
#define MsgTitle @"msgTitle"

/// JiraBot //raw,,msgTitle
#define jiraBot_cloud @"jira_cloud"
#define SourceJira @"source"
#define JiraRaw @"raw"
#define JiraStatus @"status"
#define Jiratitle @"title"
#define Jiraupdated_at @"updated_at"
#define JiraCreated_by @"created_by"
#define JiraSlug @"slug"
#define JiraAssigned_to @"assigned_to"
#define JiraType @"type"

//This feature is not active in your project. Please contact your administrator for details.

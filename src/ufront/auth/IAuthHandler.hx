package ufront.auth;

import hxevents.Dispatcher;
import hxevents.Notifier;

/**
	An interface describing an authentication handler.

	This lets you write code where the underlying authentication layer could be swapped out.
	For example, you may switch from EasyAuth (db authentication) to LDAP, or to an OAuth provider.

	Using this mechanism would allow your login checks, identity checks, and permission checks to remain the same with a different (or even multiple) login mechanisms.
	
	@author Jason O'Neil
**/
interface IAuthHandler<T>
{
	/** 
		Is a session currently open and authenticated - is the user logged in? 
	**/
	function isLoggedIn() : Bool;

	/** 
		Require the user to be logged in.  
		Otherwise trigger the `onNotLoggedIn` notifier, and throw `AuthError.NotLoggedIn`
	**/
	function requireLogin() : Void;
	
	/** 
		Is this particular user currently logged in.  Will return false if a different user is logged in. 
	**/
	function isLoggedInAs( user:T ) : Bool;

	/** 
		Require this user to be the one currently logged in.
		Otherwise will trigger `onNotLoggedInAs` dispatcher, and throw `AuthError.NotLoggedInAs( user )`
	**/
	function requireLoginAs( user:T ) : Void;

	/** 
		Does the given user have the specified permission?
		Will return false if the user is not logged in, or if the user does not have permission.
	**/
	function hasPermission( permission:EnumValue ) : Bool;

	/** 
		Does the given user have the specified permissions?
		Will return false if the user is not logged in, or if the user does not have all of the specified permissions.
	**/
	function hasPermissions( permissions:Iterable<EnumValue> ) : Bool;

	/**
		Require the given user to have the specified permission. 
		If not, trigger the `onNoPermission` dispatcher, throw `AuthError.NoPermission(permission)`.
	**/
	function requirePermission( permission:EnumValue ) : Void;

	/** 
		Require the given user to have the specified permissions. 
		If not, trigger the `onNoPermission` dispatcher, throw `AuthError.NoPermission(permission)`.
	**/
	function requirePermissions( permissions:Iterable<EnumValue> ) : Void;

	/** 
		The currently logged in user.  Will be null if no user is logged in.
	**/
	var currentUser(get,null) : Null<T>;
}
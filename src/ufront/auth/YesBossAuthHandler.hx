package ufront.auth;

import hxevents.Dispatcher;
import hxevents.Notifier;

/**
	An AuthHandler which always gives you permission to do anything.

	Useful for command line tools that don't require authentication checks.
	
	@author Jason O'Neil
**/
class YesBossAuthHandler<T:IAuthUser> implements IAuthHandler<T>
{
	/**
		Create a new YesBossAuthHandler.
	**/
	public static inline function create( context:ufront.web.context.HttpContext ) {
		return new YesBossAuthHandler();
	}

	public function new() {}

	public function isLoggedIn() return true;

	public function requireLogin() {}
	
	public function isLoggedInAs( user:T ) return true;

	public function requireLoginAs( user:T ) {}

	public function hasPermission( permission:EnumValue ) return true;

	public function hasPermissions( permissions:Iterable<EnumValue> ) return true;

	public function requirePermission( permission:EnumValue ) {}

	public function requirePermissions( permissions:Iterable<EnumValue> ) {}

	public var currentUser(get,null):Null<T>;

	function get_currentUser() return null;
}
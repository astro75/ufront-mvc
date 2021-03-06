package ufront.auth;

@:keep enum AuthError
{
	/** Thrown if Authentication fails **/
	AuthFailed;

	/** Thrown if a login is required, but the user was not logged in **/
	NotLoggedIn;

	/** Thrown if a login is required, but the user was not logged in, or is logged in as someone else **/
	NotLoggedInAs(u:IAuthUser);

	/** Thrown is a permission is required, but the user is not logged in or does not have the correct permission **/
	NoPermission(p:EnumValue);
}
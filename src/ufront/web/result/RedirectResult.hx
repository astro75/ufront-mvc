package ufront.web.result;

import hxevents.Async;
import thx.error.NullArgument;
import ufront.web.context.ActionContext;

/** Controls the processing of application actions by redirecting to a specified URI. */
class RedirectResult extends ActionResult
{
	/** The target URL. */
	public var url:String;

	/** Indicates whether the redirection should be permanent. */
	public var permanentRedirect:Bool;

	public function new( url:String, ?permanentRedirect=false ) {
		NullArgument.throwIfNull(url);
		this.url = url;
		this.permanentRedirect = permanentRedirect;
	}

	override function executeResult( actionContext:ActionContext, async:Async ) {
		// Clear content and headers, but not cookies
		actionContext.response.clearContent();
		actionContext.response.clearHeaders();

		if(permanentRedirect) actionContext.response.permanentRedirect( url );
		else actionContext.response.redirect( url );
		
		async.completed();
	}
}
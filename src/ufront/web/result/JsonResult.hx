package ufront.web.result;
import hxevents.Async;
import thx.json.Json;
import thx.error.NullArgument;
import ufront.web.context.ActionContext;

/** Represents a class that is used to send JSON-formatted content to the response. */
class JsonResult<T> extends ActionResult
{
	/** The content to be serialized **/
	public var content : T;
	public var allowOrigin : String;

	public function new( content:T ) {
		this.content = content;
	}

	override function executeResult( actionContext:ActionContext, async:Async ) {
		NullArgument.throwIfNull(actionContext);

		actionContext.response.contentType = "application/json";
		var serialized = Json.encode(content);
		actionContext.response.write(serialized);
		async.completed();
	}
}
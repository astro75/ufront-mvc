package ufront.web.result;

import hxevents.Async;
import ufront.web.context.ActionContext;

/**
 * Represents a result that does nothing, such as a controller action method that returns nothing.
 * @author Andreas Soderlund
 */

class EmptyResult extends ActionResult
{
	public function new(){}
	
	override public function executeResult( actionContext:ActionContext, async:Async ) {
		async.completed();
	}
}
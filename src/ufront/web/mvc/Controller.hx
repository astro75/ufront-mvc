package ufront.web.mvc;
import ufront.web.HttpContext;
import udo.error.Error;
import ufront.web.mvc.ControllerContext;
import ufront.web.routing.RequestContext;
import ufront.web.mvc.Controller;

class Controller implements haxe.rtti.Infos
{                               
	static inline var DEFAULT_ACTION = "index";
	var _invoker : MethodInvoker;
	var _defaultAction : String;
	function new()
	{
		_invoker = new MethodInvoker(); 
		_defaultAction = DEFAULT_ACTION;
	}
	
	public var httpContext(default, null) : HttpContext;
	
	public function execute(requestContext : RequestContext)
	{          
		httpContext = requestContext.httpContext;
		
		var context = new ControllerContext(this, requestContext);
		
		var action = requestContext.routeData.get("action");
		if(null == action)
		{
			requestContext.routeData.data.set("action", action = _defaultAction);
		}
 
		if(!_invoker.invoke(this, action, context))
			_handleUnknownAction(action);
	}
	
	function _handleUnknownAction(action : String)
	{
		throw new Error("action {0} can't be executed because {1}", [action, _invoker.error.toString()]);
	}
}
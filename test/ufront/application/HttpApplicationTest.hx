package ufront.application;

import massive.munit.Assert;
import thx.error.*;
import ufront.application.HttpApplication;
import hxevents.AsyncDispatcher;
import hxevents.Dispatcher;
import ufront.module.IHttpModule;
import ufront.web.url.filter.IUrlFilter;
import ufront.web.context.*;
using ufront.test.TestUtils;
using mockatoo.Mockatoo;

class HttpApplicationTest 
{
	var context:HttpContext; 
	var instance:HttpApplication; 
	
	public function new() 
	{
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
		context = "/".mockHttpContext();
		instance = new HttpApplication();
		modulesInitiated = [];
		modulesDisposed = [];
		eventsFired = [];
	}
	
	@After
	public function tearDown():Void
	{
		context = null;
		instance = null;
		modulesInitiated = null;
		modulesDisposed = null;
		eventsFired = null;
	}
	
	@Test
	public function testNew():Void
	{
		// Test events are initialized

		Assert.isNotNull( instance.onBeginRequest );
		Assert.isType( instance.onBeginRequest, AsyncDispatcher );
		
		Assert.isNotNull( instance.onResolveRequestCache );
		Assert.isType( instance.onResolveRequestCache, AsyncDispatcher );
		
		Assert.isNotNull( instance.onPostResolveRequestCache );
		Assert.isType( instance.onPostResolveRequestCache, AsyncDispatcher );
		
		Assert.isNotNull( instance.onDispatch );
		Assert.isType( instance.onDispatch, AsyncDispatcher );
		
		Assert.isNotNull( instance.onPostDispatch );
		Assert.isType( instance.onPostDispatch, AsyncDispatcher );
		
		Assert.isNotNull( instance.onActionExecute );
		Assert.isType( instance.onActionExecute, AsyncDispatcher );
		
		Assert.isNotNull( instance.onPostActionExecute );
		Assert.isType( instance.onPostActionExecute, AsyncDispatcher );
		
		Assert.isNotNull( instance.onResultExecute );
		Assert.isType( instance.onResultExecute, AsyncDispatcher );
		
		Assert.isNotNull( instance.onPostResultExecute );
		Assert.isType( instance.onPostResultExecute, AsyncDispatcher );
		
		Assert.isNotNull( instance.onUpdateRequestCache );
		Assert.isType( instance.onUpdateRequestCache, AsyncDispatcher );
		
		Assert.isNotNull( instance.onPostUpdateRequestCache );
		Assert.isType( instance.onPostUpdateRequestCache, AsyncDispatcher );
		
		Assert.isNotNull( instance.onLogRequest );
		Assert.isType( instance.onLogRequest, AsyncDispatcher );
		
		Assert.isNotNull( instance.onPostLogRequest );
		Assert.isType( instance.onPostLogRequest, AsyncDispatcher );
		
		Assert.isNotNull( instance.onEndRequest );
		Assert.isType( instance.onEndRequest, Dispatcher );
		
		Assert.isNotNull( instance.onApplicationError );
		Assert.isType( instance.onApplicationError, AsyncDispatcher );

		// Test onPostLogRequest has at least one event handler
		Assert.isTrue( instance.onPostLogRequest.has() );
	}

	@Test
	public function testAddModules():Void
	{
		addModules();

		// Test the modules are in the list
		Assert.areEqual( 2, instance.modules.length );
	}

	@Test
	public function testExecute():Void
	{
		addModules();
		addEvents();
		instance.execute( context );

		// Test the modules have been initiated
		Assert.areEqual( 2, modulesInitiated.length );
		Assert.areEqual( "Module1,Module2", modulesInitiated.join(",") );

		// Test the events fire in order
		Assert.areEqual( 14, eventsFired.length );
		Assert.areEqual( "onBeginRequest", eventsFired[0] );
		Assert.areEqual( "onResolveRequestCache", eventsFired[1] );
		Assert.areEqual( "onPostResolveRequestCache", eventsFired[2] );
		Assert.areEqual( "onDispatch", eventsFired[3] );
		Assert.areEqual( "onPostDispatch", eventsFired[4] );
		Assert.areEqual( "onActionExecute", eventsFired[5] );
		Assert.areEqual( "onPostActionExecute", eventsFired[6] );
		Assert.areEqual( "onResultExecute", eventsFired[7] );
		Assert.areEqual( "onPostResultExecute", eventsFired[8] );
		Assert.areEqual( "onUpdateRequestCache", eventsFired[9] );
		Assert.areEqual( "onPostUpdateRequestCache", eventsFired[10] );
		Assert.areEqual( "onLogRequest", eventsFired[11] );
		Assert.areEqual( "onPostLogRequest", eventsFired[12] );
		Assert.areEqual( "onEndRequest", eventsFired[13] );

		// Test that the response was flushed,
		Assert.isTrue( context.response.flush().verify() );

		// Test the context was disposed
		Assert.isTrue( context.dispose().verify() );
	}

	@Test
	public function testExecuteErrorNoHandler():Void
	{
		addModules();
		addEvents();
		instance.onResolveRequestCache.add( function(app) throw "ouch" );

		// With no listener, it should throw an error
		try {
			instance.execute( context );
			Assert.fail( "Exception was not thrown" );
		}
		catch ( e:Dynamic ) {
			Assert.isType( e, Error );
			Assert.areEqual( "ouch", e.toString() );
		}

		// Test the events fired, stopped when error thrown, and then finished
		Assert.areEqual( "onBeginRequest", eventsFired[0] );
		Assert.areEqual( "onResolveRequestCache", eventsFired[1] );
		Assert.areEqual( "onLogRequest", eventsFired[2] );
		Assert.areEqual( "onPostLogRequest", eventsFired[3] );
		Assert.areEqual( 4, eventsFired.length );
	}

	@Test
	public function testExecuteErrorWithHandler():Void
	{
		addModules();
		addEvents();
		instance.onResolveRequestCache.add( function(app) throw "ouch" );
		instance.onApplicationError.add( 
			function(event:{ error:Error, context:HttpContext }) {
				eventsFired.push("onApplicationError");
				Assert.isType( event.error, Error );
				Assert.areEqual( "ouch", event.error.toString() );
			}
		);
		instance.execute( context );

		// Test the events fired, stopped when error thrown, and then finished
		Assert.areEqual( "onBeginRequest", eventsFired[0] );
		Assert.areEqual( "onResolveRequestCache", eventsFired[1] );
		Assert.areEqual( "onLogRequest", eventsFired[2] );
		Assert.areEqual( "onPostLogRequest", eventsFired[3] );
		Assert.areEqual( "onApplicationError", eventsFired[4] );
		Assert.areEqual( "onEndRequest", eventsFired[5] );
		Assert.areEqual( 6, eventsFired.length );
	}

	@Test
	public function testCompleteRequest():Void
	{
		addModules();
		addEvents();
		instance.onResolveRequestCache.add( function(context) context.completed=true );
		instance.execute( context );

		// Test the events fired, stopped when completeRequest() was called, and then finished
		Assert.areEqual( 3, eventsFired.length );
		Assert.areEqual( "onBeginRequest", eventsFired[0] );
		Assert.areEqual( "onResolveRequestCache", eventsFired[1] );
		Assert.areEqual( "onEndRequest", eventsFired[2] );
	}

	@Test
	public function testInitModulesAndDispose():Void
	{
		addModules();
		addEvents();
		instance.initModules();

		// Test the modules have been initiated
		Assert.areEqual( 2, modulesInitiated.length );
		Assert.areEqual( "Module1,Module2", modulesInitiated.join(",") );

		instance.dispose();

		// Test the modules were disposed
		Assert.areEqual( 2, modulesDisposed.length );
		Assert.areEqual( "Module1,Module2", modulesDisposed.join(",") );
	}

	@Test
	public function testUrlFilters():Void
	{
		instance.addUrlFilter( IUrlFilter.mock() );
		instance.addUrlFilter( IUrlFilter.mock() );
		try {
			instance.addUrlFilter( null );
			Assert.fail( "Did not throw error when adding Null UrlFilter" );
		} catch (e:NullArgument) {}

		Assert.areEqual( 2, instance.urlFilters.length );
		
		instance.clearUrlFilters();

		Assert.areEqual( 0, instance.urlFilters.length );
	}

	var modulesInitiated:Array<String>;
	var modulesDisposed:Array<String>;
	var eventsFired:Array<String>;
	
	// add modules to the current instance
	function addModules()
	{
		var module1 = new TestModule(modulesInitiated,modulesDisposed,"Module1");
		var module2 = new TestModule(modulesInitiated,modulesDisposed,"Module2");
		instance.addModule( module1 );
		instance.addModule( module2 );
	}
	
	// add modules to the current instance
	function addEvents()
	{
		var f = function(name:String, context:HttpContext) eventsFired.push(name);

		instance.onBeginRequest.add( f.bind("onBeginRequest") );
		instance.onResolveRequestCache.add( f.bind("onResolveRequestCache") );
		instance.onPostResolveRequestCache.add( f.bind("onPostResolveRequestCache") );
		instance.onDispatch.add( f.bind("onDispatch") );
		instance.onPostDispatch.add( f.bind("onPostDispatch") );
		instance.onActionExecute.add( f.bind("onActionExecute") );
		instance.onPostActionExecute.add( f.bind("onPostActionExecute") );
		instance.onResultExecute.add( f.bind("onResultExecute") );
		instance.onPostResultExecute.add( f.bind("onPostResultExecute") );
		instance.onUpdateRequestCache.add( f.bind("onUpdateRequestCache") );
		instance.onPostUpdateRequestCache.add( f.bind("onPostUpdateRequestCache") );
		instance.onLogRequest.add( f.bind("onLogRequest") );
		instance.onPostLogRequest.add( f.bind("onPostLogRequest") );
		instance.onEndRequest.add( f.bind("onEndRequest") );
	}
}

private class TestModule implements IHttpModule
{
	var initiated:Array<String>;
	var disposed:Array<String>;
	var name:String;

	public function new( initiated, disposed, name ) {
		this.initiated = initiated;
		this.disposed = disposed;
		this.name = name;
	}

	public function init( httpApplication:HttpApplication ) {
		initiated.push( name );
	}

	public function dispose() {
		disposed.push( name );
	}
}
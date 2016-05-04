var balls:Vector.<MovieClip>=Vector.<MovieClip>([one,two,three, four, five, six, seven]);

var md:Boolean=false;
var mx:int=200;
var my:int=200;
var oldx:int=200;
var oldy:int=200;
var inter:int=200;
var steep:Boolean=false;
var vx:int=0;
var vy:int=0;

addEventListener(Event.ENTER_FRAME, enterFrame);
stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
stage.addEventListener(MouseEvent.MOUSE_DOWN, down);
stage.addEventListener(MouseEvent.MOUSE_UP, up);

function move(event:MouseEvent):void{
	mx=event.stageX;
	my=event.stageY;
	var dx:Number=mx-one.x;
	var dy:Number=my-one.y;
	if(md){
		var rot:Number=stick.rotation/180*Math.PI;
		if(steep){
			stick.y=my;
			stick.x=1/Math.tan(rot)*my+inter;
		}else{
			stick.x=mx;
			stick.y=Math.tan(rot)*mx+inter;
		}
		//caclulate velocity
		vx=stick.x-oldx;
		vy=stick.y-oldy;
		//do we hit
		var tip:Point=stick.localToGlobal(new Point(-75, 0));
		dx=tip.x-one.x;
		dy=tip.y-one.y;
		var dis:Number=Math.sqrt(dx*dx+dy*dy);
		if(dis<one.width/2){
			one.vx+=vx;
			one.vy+=vy;
		}
	}else{
		stick.x=mx;
		stick.y=my;
		stick.rotation=Math.atan2(dy,dx)/Math.PI*180;
	}
	oldx=stick.x;
	oldy=stick.y;
}

function down(event:MouseEvent):void{
	md=true;
	var rot:Number=stick.rotation/180*Math.PI;
	if(Math.abs(Math.sin(rot))<Math.abs(Math.cos(rot))){
		stick.x=mx;
		inter=stick.y-Math.tan(rot)*mx;
		steep=false;
	}else{
		steep=true;
		stick.y=my;
		inter=stick.x-1/Math.tan(rot)*my;
	}
}

function up(event:MouseEvent):void{
	md=false;
}

function enterFrame(event:Event):void{
	var ball:MovieClip;
	for(var n:int=0;n<balls.length;n++){
		ball=balls[n];
		for(var m:int=n+1;m<balls.length;m++){
			var otherBall:MovieClip=balls[m];
			var dx:int=ball.x-otherBall.x;
			var dy:int=ball.y-otherBall.y;
			var dis:Number=Math.sqrt(dx*dx+dy*dy);
			var radiusSum:int=ball.width/2+otherBall.width/2;
			if(dis<radiusSum){
				//calculate scale ratios
				var bo:Number=Math.pow(ball.width/otherBall.width/2, 2);
				var ob:Number=Math.pow(otherBall.width/ball.width/2, 2);
				
				//calculate trig ratios
				var cosa:Number=dx/dis;
				var sina:Number=dy/dis;
				
				//move the balls out of each other
				var midx:Number=(ball.x+otherBall.x)/2;
				var midy:Number=(ball.y+otherBall.y)/2;
				ball.x=midx+cosa*radiusSum/2;
				ball.y=midy+sina*radiusSum/2;
				otherBall.x=midx-cosa*radiusSum/2;
				otherBall.y=midy-sina*radiusSum/2;
				
				//calculate the new velocities
				var vx2:Number=cosa*ball.vx*bo+sina*ball.vy*bo;
				var vy1:Number=cosa*ball.vy*bo-sina*ball.vx*bo;
				var vx1:Number=cosa*otherBall.vx*ob+sina*otherBall.vy*ob;
				var vy2:Number=cosa*otherBall.vy*ob-sina*otherBall.vx*ob;
				//calculate sppeds
				var bx:Number=cosa*vx1 - sina*vy1;
				var by:Number=cosa*vy1 + sina*vx1;
				var obx:Number=cosa*vx2 - sina*vy2;
				var oby:Number=(cosa*vy2 + sina*vx2);
				
				//
				ball.vx=bx/bo;
				ball.vy=by/bo;
				otherBall.vx=obx/ob;
				otherBall.vy=oby/ob;				
			}
		}
	}
	for(n=0;n<balls.length;n++){
		ball=balls[n];
		if(ball.x-ball.width/2<0){
			ball.x=ball.width/2;
			if(ball.vx<0){
				ball.vx*=-1;
			}
		}else if(ball.x+ball.width/2>stage.stageWidth){
			ball.x=stage.stageWidth-ball.width/2;
			if(ball.vx>0){
				ball.vx*=-1;
			}
		}
		if(ball.y-ball.width/2<0){
			ball.y=ball.width/2;
			if(ball.vy<0){
				ball.vy*=-1;
			}
		}else if(ball.y+ball.width/2>stage.stageHeight){
			ball.y=stage.stageHeight-ball.width/2;
			if(ball.vy>0){
				ball.vy*=-1;
			}
		}
		//friction
		ball.vx*=0.99;
		ball.vy*=0.99;
		if(Math.abs(ball.vx)<0.01){
			ball.vx=0;
		}
		if(Math.abs(ball.vy)<0.01){
			ball.vy=0;
		}
		ball.x+=ball.vx;
		ball.y+=ball.vy;
		//re draw
		ball.graphics.clear();
		var fillType:String = GradientType.RADIAL;
		var colors:Array = [0xffffff, ball.color, 0x000000];
  		var alphas:Array = [1, 1, 1];
 		var ratios:Array = [0, 48, 255];
  		var matr:Matrix = new Matrix();
		var lightSize:int=95;
		var dist:Number=0.15*(20/ball.width);
  		matr.createGradientBox(lightSize, lightSize, 0, dist*(stage.stageWidth/2-ball.x)-lightSize/2, dist*(stage.stageHeight/2-ball.y)-lightSize/2);
 		var spreadMethod:String = SpreadMethod.PAD;
  		ball.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
		ball.graphics.drawCircle(0,0,ball.width/2/ball.scaleX);
		ball.graphics.endFill();
	}
}
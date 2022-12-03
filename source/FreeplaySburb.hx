package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

using StringTools;

class FreeplaySburb extends MusicBeatState
{
	public static var curCategory:String = 'Main'; //This is also used for Discord RPC
	var curSelected:Int = -1;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var covers:FlxTypedGroup<FlxSprite>;
	
	var songs:Map<String, Array<Dynamic>> = [
		'Main' => [
			['Prankster', 'egbert'],
			['Grimoire', 'rose'],
			['Record-Scratch', 'dave'],
			['Sunshatter', 'jade'],
		],
		'Misc' => [
			['Abjure', 'abjure'],
		],
		'Covers' => [
			['Showtime', 'bonus'],
		],
	];

	var debugKeys:Array<FlxKey>;

	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('freeplaySel/bg', "sburb"));
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var baseCover:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('freeplay/i-' + curCategory.toLowerCase(), "sburb"));
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		baseCover.updateHitbox();
		baseCover.screenCenter();
		baseCover.antialiasing = ClientPrefs.globalAntialiasing;
		add(baseCover);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		covers = new FlxTypedGroup<FlxSprite>();
		add(covers);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...songs.get(curCategory).length)
		{
			var menuItem:FlxSprite = new FlxSprite(-200, 300 + (i * 43));
			menuItem.loadGraphic(Paths.image('freeplay/' + songs.get(curCategory)[i][0].toLowerCase(), "sburb"));
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x -= 290;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.updateHitbox();

			var coverArt:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('freeplay/i-' + songs.get(curCategory)[i][1].toLowerCase(), "sburb"));
			//bg.setGraphicSize(Std.int(bg.width * 1.175));
			coverArt.alpha = 0;
			coverArt.updateHitbox();
			coverArt.screenCenter();
			coverArt.antialiasing = ClientPrefs.globalAntialiasing;
			coverArt.ID = i;
			covers.add(coverArt);
		}
		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);

		if (!selectedSomethin)
		{
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			menuItems.forEach(function(spr:FlxSprite)
			{
				if(FlxG.mouse.overlaps(spr)){
					curSelected = spr.ID;
					if(FlxG.mouse.justPressed){
						var songLowercase:String = Paths.formatToSongPath(songs.get(curCategory)[spr.ID][0].toLowerCase());
						var poop:String = Highscore.formatSong(songLowercase, 1);
						trace(poop);

						PlayState.SONG = Song.loadFromJson(poop, songLowercase);
						PlayState.isStoryMode = false;
						PlayState.storyDifficulty = 1;

						LoadingState.loadAndSwitchState(new PlayState());

						selectedSomethin = true;
						FlxG.sound.play(Paths.sound("confirmMenu"), 0.7);
						//FlxG.camera.fade(FlxColor.WHITE,1);
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							//song code goes here lmaoooooooooooooooooooooooooo
						});
					}
				}
				else{
					curSelected = -1;
				}
			});

			covers.forEach(function(spr:FlxSprite)
			{
				if(spr.ID == curSelected){
					spr.alpha = 1;
				}
				else{
					spr.alpha = 0;
				}
			});
		}

		super.update(elapsed);
	}
}

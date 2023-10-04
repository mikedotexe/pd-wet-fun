import "sounds/soundmanager.lua"

snd = playdate.sound
sound_manager = SoundManager:new()
timer = playdate.timer
sample = snd.sampleplayer.new("assets/audio-8000")
sample:setFinishCallback(function() print("finished!") end)

playdate.graphics.drawText("Press B to splash! A for 'game over' sound.", 45, 100)

b_button_synths = {}
a_button_synths = {}

function playdate.BButtonDown()
	-- Fade out all sounds from A
	for _, record in ipairs(a_button_synths) do
		record.fadeDuration = 0.666
		record.time = snd.getCurrentTime()
	end
	local splash_synth = sound_manager:splashSound()
	
	table.insert(b_button_synths, {time = snd.getCurrentTime(), synth = splash_synth, fadeDuration = 1.9})
end

function playdate.AButtonDown()
	-- Fade out all sounds from B
	for _, record in ipairs(b_button_synths) do
		record.fadeDuration = 0.666
		record.time = snd.getCurrentTime()
	end
	
	local game_over_synth = sound_manager:gameOverSound()
	table.insert(a_button_synths, {time = snd.getCurrentTime(), synth = game_over_synth, fadeDuration = 0.42})
end

t = 0

function playdate.update()
	t += 1
	
	if t % 3 == 0 then
		update_time = snd.getCurrentTime()
		-- print(t .. " with time " .. update_time)
		
		local currentTime = snd.getCurrentTime()
		
		for i = #b_button_synths
	, 1, -1 do
			local record = b_button_synths
		[i]
			local elapsed = currentTime - record.time
			
			local fadeDuration = record.fadeDuration
			
			if elapsed > fadeDuration then
				local fadeAmount = math.max(0, 1 - (elapsed - fadeDuration))
				if record and record.synth then
					record.synth:setVolume(fadeAmount)
					print("Saving volume to " .. fadeAmount)
				end				
				
				-- When volume finishes fading, remove the record from the B synth table
				if fadeAmount <= 0 then
					table.remove(b_button_synths
					, i)
				end
			end
		end
		
		for i = #a_button_synths, 1, -1 do
			local record = a_button_synths[i]
			local elapsed = currentTime - record.time
			
			local fadeDuration = record.fadeDuration or .666
			
			if elapsed > fadeDuration then
				local fadeAmount = math.max(0, 1 - (elapsed - fadeDuration))
				

				if record and record.synth then					
					local lfo = snd.lfo.new(snd.kLFOSquare)
					lfo:setRate(300) -- Experiment with this to find the best 'white noise' approximation
					lfo:setDepth(fadeAmount * 1.9)
					record.synth:setFrequencyMod(lfo)
					record.synth:setVolume(fadeAmount)
					print("Setting depth to " .. fadeAmount)
				end
				
				-- If volume is fully faded, remove the record from the table.
				if fadeAmount <= 0 then
					table.remove(a_button_synths
					, i)
				end
			end		
		end
	end
end

--- Code from before that might be useful:

synthtests =
{
-- 	function()
-- 		synth = snd.synth.new(snd.kWaveSine)
-- 		synth:setDecay(0.1)
-- 		synth:setSustain(0.1)
-- 		-- timer.scheduleRepeating(function()
-- 		-- 	synth:playNote(60)  -- Bass Drum
-- 		-- 	playdate.timer.delay(0.5, function()
-- 		-- 		synth:playNote(60)  -- Bass Drum
-- 		-- 	end)
-- 		-- end, 1.0)  -- Repeat every second to match the tempo of "Never Gonna Give You Up"
-- 		-- playdate.timer.new(666, function()
-- 		-- 	synth:playNote(60)  -- Bass Drum
-- 		-- end)
-- 		synth:playNote(90)  -- Bass Drum
-- 	end,
	-- playdate.sound.synth
	function()
		synth = snd.synth.new(snd.kWaveSawtooth)
		synth:playNote(220)
	end,
	
	function()
		synth:stop()
		synth:setDecay(0.5)
		synth:setSustain(0)
		synth:playNote(330)
	end,
	
	function()
		lfo = snd.lfo.new(snd.kLFOSampleAndHold)
		lfo:setRate(10)
		lfo:setDepth(2)
		synth:setFrequencyMod(lfo)
		synth:playNote(220)
	end,
	
	function()
		--synth:setFrequencyLFO(nil) -- XXX - can't clear it by setting to nil: function uses testudata to check object type
		filter = snd.twopolefilter.new("lowpass") -- XXX - snd.kFilterLowPass should work
		filter:setResonance(0.95)
		filter:setFrequency(1000)
		snd.addEffect(filter) -- XXX - addFilter() is a synonym. Is one of these deprecated?
		synth:playNote(220)
	end,
	
	function()
		snd.removeEffect(filter)
	end
}

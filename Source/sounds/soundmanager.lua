SoundManager = {}
SoundManager.__index = SoundManager

snd = playdate.sound

function SoundManager.new()
	local self = setmetatable({}, SoundManager)
	self.activeEffects = {}
	return self
end

function SoundManager:addEffect(effect)
	table.insert(self.activeEffects, effect)
	snd.addEffect(effect)
end

function SoundManager:clearEffects()
	for _, effect in ipairs(self.activeEffects) do
		snd.removeEffect(effect)
	end
	self.activeEffects = {}
end

function SoundManager:gameOverSound()
	self:clearEffects()
	
	local synth = snd.synth.new(snd.kWaveSquare)
	
	local hipass = snd.twopolefilter.new("hipass")
	hipass:setFrequency(600)
	self:addEffect(hipass)

	local lopass = snd.twopolefilter.new("lowpass")
	lopass:setFrequency(6660)
	self:addEffect(lopass)

	synth:playNote(190)
	
	return synth
end

function SoundManager:splashSound()
	self:clearEffects()
	
	local synth = snd.synth.new(snd.kWaveSine)
	lfo = snd.lfo.new(snd.kLFOSampleAndHold)
	lfo:setRate(60)
	lfo:setDepth(0.7)
	synth:setFrequencyMod(lfo)
	synth:setDecay(0.3)
	synth:setSustain(0.01)
	
	filter = snd.twopolefilter.new("lowpass")
	bandpass_filter = snd.twopolefilter.new("notch")
	bandpass_filter:setFrequency(550)
	self:addEffect(bandpass_filter)
	
	filter:setResonance(0.55)
	filter:setFrequency(666)
	self:addEffect(filter)
	
	synth:playNote(31)
	synth:setSustain(0.01)
	synth:setDecay(0.9)
	synth:playNote(240)
	
	return synth
end

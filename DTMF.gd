extends AudioStreamPlayer
var playback # Will hold the AudioStreamGeneratorPlayback.
@onready var sample_hz = self.stream.mix_rate
var pulse_hz = 440.0 # The frequency of the sound wave.
var phase = 0.0

func _ready():
	return

func fill_buffer():
	var increment = pulse_hz / sample_hz
	var frames_available = playback.get_frames_available()

	for i in range(frames_available):
		playback.push_frame(Vector2.ONE * sin(phase * TAU))
		phase = fmod(phase + increment, 1.0)

func dialTone(input : String):
	match input:
		"#":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 941, 1477)
		"0":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 941, 1336)
		"*":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 941, 1209)
		"D":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 941, 1633)
		
		"7":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 852, 1209)
		"8":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 852, 1336)
		"9":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 852, 1477)
		"C":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 852, 1633)
		
		"4":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 770, 1209)
		"5":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 770, 1336)
		"6":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 770, 1477)
		"B":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 770, 1633)
		
		"1":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 697, 1209)
		"2":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 697, 1336)
		"3":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 697, 1477)
		"A":
			self.play()
			playback = self.get_stream_playback()
			build_sine(0, 697, 1633)
		
			

var phase1 = 0.0
var phase2 = 0.0

func generateWave(pitch1, pitch2):
#generate the first wave
	var wave1 = sin(phase1*TAU)
	var increment = (pitch1 / sample_hz)
	phase1 = fmod(phase1 + increment, 1.0)
#generate the second wave
	var wave2 = sin(phase2*TAU)
	increment = (pitch2 / sample_hz)
	phase2 = fmod(phase2 + increment, 1.0)
	#add them together
	var wave = wave1+wave2
#divide the added wave by 2 to prevent clipping/distortion
	wave = wave/2
	return wave
	
func build_sine(pitch, pitch1, pitch2):
	playback = get_stream_playback()
	var phase3 = 0.0
	var increment = pitch / sample_hz
	var frames_available = playback.get_frames_available()/4
	for i in range(frames_available):
		phase = fmod(phase3 + increment, 1.0)
		playback.push_frame(Vector2.ONE * generateWave(pitch1, pitch2))

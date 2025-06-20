import AVFoundation
import Copus
import CopusWrap

extension Opus {
	public class Encoder {
		let format: AVAudioFormat
		let application: Application
		let encoder: OpaquePointer

		// TODO: throw an error if format is unsupported
		public init(format: AVAudioFormat, application: Application = .audio) throws {
			if !format.isValidOpusPCMFormat {
				throw Opus.Error.badArgument
			}

			self.format = format
			self.application = application

			// Initialize Opus encoder
			var error: Opus.Error = .ok
			encoder = opus_encoder_create(Int32(format.sampleRate), Int32(format.channelCount), application.rawValue, &error.rawValue)
			if error != .ok {
				throw error
			}
		}

		deinit {
			opus_encoder_destroy(encoder)
		}

		public func reset() throws {
			let error = Opus.Error(opus_encoder_init(encoder, Int32(format.sampleRate), Int32(format.channelCount), application.rawValue))
			if error != .ok {
				throw error
			}
		}
	}
}

// MARK: Public encode methods

extension Opus.Encoder {
	public func encode(_ input: AVAudioPCMBuffer, to output: inout Data) throws -> Int {
		output.count = try output.withUnsafeMutableBytes {
			try encode(input, to: $0)
		}
		return output.count
	}

	public func encode(_ input: AVAudioPCMBuffer, to output: inout [UInt8]) throws -> Int {
		try output.withUnsafeMutableBufferPointer {
			try encode(input, to: $0)
		}
	}

	public func encode(_ input: AVAudioPCMBuffer, to output: UnsafeMutableRawBufferPointer) throws -> Int {
		let output = UnsafeMutableBufferPointer(start: output.baseAddress!.bindMemory(to: UInt8.self, capacity: output.count), count: output.count)
		return try encode(input, to: output)
	}

	public func encode(_ input: AVAudioPCMBuffer, to output: UnsafeMutableBufferPointer<UInt8>) throws -> Int {
		guard input.format.sampleRate == format.sampleRate, input.format.channelCount == format.channelCount else {
			throw Opus.Error.badArgument
		}
		switch format.commonFormat {
		case .pcmFormatInt16:
			let input = UnsafeBufferPointer(start: input.int16ChannelData![0], count: Int(input.frameLength * format.channelCount))
			return try encode(input, to: output)
		case .pcmFormatFloat32:
			let input = UnsafeBufferPointer(start: input.floatChannelData![0], count: Int(input.frameLength * format.channelCount))
			return try encode(input, to: output)
		default:
			throw Opus.Error.badArgument
		}
	}

	public func setVBR(_ vbr: Bool) throws {
		let error: Opus.Error
		if vbr {
			error = Opus.Error(opus_encoder_set_vbr(encoder, 1))
		}
		else {
			error = Opus.Error(opus_encoder_set_vbr(encoder, 0))
		}
		if error != .ok {
			throw error
		}
	}

	public func setBitrate(_ bitrate: Int) throws {
		try? self.setVBR(false)
		let error: Opus.Error = Opus.Error(opus_encoder_set_bitrate(encoder, Int32(bitrate)))
		if error != .ok {
			throw error
		}
	}
}

// MARK: pointer encode methods

extension Opus.Encoder {
	public func encode(_ input: UnsafeBufferPointer<Int16>, to output: UnsafeMutableBufferPointer<UInt8>) throws -> Int {
		let encodedSize = opus_encode(
			encoder,
			input.baseAddress!,
			Int32(input.count) / Int32(format.channelCount),
			output.baseAddress!,
			Int32(output.count)
		)
		if encodedSize < 0 {
			throw Opus.Error(encodedSize)
		}
		return Int(encodedSize)
	}

	public func encode(_ input: UnsafeBufferPointer<Float32>, to output: UnsafeMutableBufferPointer<UInt8>) throws -> Int {
		let encodedSize = opus_encode_float(
			encoder,
			input.baseAddress!,
			Int32(input.count) / Int32(format.channelCount),
			output.baseAddress!,
			Int32(output.count)
		)
		if encodedSize < 0 {
			throw Opus.Error(encodedSize)
		}
		return Int(encodedSize)
	}
}

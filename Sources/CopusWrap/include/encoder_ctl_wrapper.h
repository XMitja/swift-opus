#ifndef __C_OPUS_WRAP_H__
#define __C_OPUS_WRAP_H__
#include <opus.h>

#ifdef __cplusplus
extern "C" {
#endif

// since swift doesn't support vararg
// requests defined in opus_defines.h
int opus_encoder_ctl_2(OpusEncoder *enc, int request, int value);
// same as opus_encoder_ctl_2(enc, 4006, vbr)
int opus_encoder_set_vbr(OpusEncoder *enc, int vbr);
// same as opus_encoder_ctl_2(enc, 4002, bitrate)
int opus_encoder_set_bitrate(OpusEncoder *enc, int bitrate);

#ifdef __cplusplus
}
#endif

#endif

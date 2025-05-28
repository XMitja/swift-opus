#include "encoder_ctl_wrapper.h"

int opus_encoder_set_vbr(OpusEncoder *enc, int vbr) {
    return opus_encoder_ctl(enc, OPUS_SET_VBR(vbr));
}

int opus_encoder_set_bitrate(OpusEncoder *enc, int bitrate) {
    return opus_encoder_ctl(enc, OPUS_SET_BITRATE(bitrate));
}

int opus_encoder_ctl_2(OpusEncoder *enc, int request, int value) {
    return opus_encoder_ctl(enc, request, value);
}

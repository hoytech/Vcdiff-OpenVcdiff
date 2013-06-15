#ifdef __cplusplus
extern "C" {
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef __cplusplus
}
#endif


#include <google/vcdecoder.h>
#include <google/vcencoder.h>

#include <memory>


// FIXME: figure out the right value for this: maybe dynamic?
#define BUF_SIZE 65536


int encode(int source_fd, SV *source_sv, int input_fd, SV *input_sv, int output_fd, SV *output_sv) {
  std::auto_ptr<open_vcdiff::HashedDictionary> hashed_dictionary;

  if (source_fd != -1) {
    return -1; // not impl
  } else {
    char *source_str;
    size_t source_str_size;

    source_str_size = SvCUR(source_sv);
    source_str = SvPV(source_sv, source_str_size);
    hashed_dictionary.reset(new open_vcdiff::HashedDictionary(source_str, source_str_size));
  }

  if (!hashed_dictionary->Init()) {
    return 1;
  }

  open_vcdiff::VCDiffFormatExtensionFlags format_flags = open_vcdiff::VCD_STANDARD_FORMAT;
  open_vcdiff::VCDiffStreamingEncoder encoder(hashed_dictionary.get(), format_flags, false);

  std::string output_string;

  if (!encoder.StartEncoding(&output_string)) {
    return 2;
  }


  char *ibuf_ptr = NULL;
  std::string ibuf_str;
  size_t ibuf_len = 0;
  char *input_str_ptr = NULL;
  size_t input_str_size = 0;

  if (input_fd != -1) {
    ibuf_str.resize(BUF_SIZE);
    lseek(input_fd, 0, SEEK_SET); // ignore errors: FIXME: consider if we should even do this
  } else {
    input_str_size = SvCUR(input_sv);
    input_str_ptr = SvPV(input_sv, input_str_size);
    ibuf_ptr = input_str_ptr;
  }


  while(1) {
    if (input_fd != -1) {
      ibuf_len = read(input_fd, &ibuf_str[0], BUF_SIZE);
      if (ibuf_len < 0) {
        return 4;
      }
    } else {
      ibuf_ptr += ibuf_len;
      ibuf_len = MIN(BUF_SIZE, input_str_size - (ibuf_ptr - input_str_ptr));
    }

    if (ibuf_len == 0) break;

    if (!encoder.EncodeChunk((input_fd != -1) ? &ibuf_str[0] : ibuf_ptr, ibuf_len, &output_string)) {
      return 5;
    }

    if (output_fd != -1) {
      if (write(output_fd, output_string.c_str(), output_string.length()) != output_string.length()) {
        return 6;
      }

      output_string.clear();
    }

    if (input_fd != -1 && ibuf_len < BUF_SIZE) break; // stream is empty
  }


  if (!encoder.FinishEncoding(&output_string)) {
    return 7;
  }


  if (output_fd != -1) {
    if (write(output_fd, output_string.c_str(), output_string.length()) != output_string.length()) {
      return 8;
    }

    output_string.clear();
  } else {
    sv_catpvn(output_sv, output_string.c_str(), output_string.length());
  }


  return 0;
}


int decode(int source_fd, SV *source_sv, int input_fd, SV *input_sv, int output_fd, SV *output_sv) {
  return -1;
}











MODULE = Vcdiff::OpenVcdiff        PACKAGE = Vcdiff::OpenVcdiff
 
PROTOTYPES: ENABLE


int
_encode(source_fd, source_sv, input_fd, input_sv, output_fd, output_sv)
        int source_fd
        SV *source_sv
        int input_fd
        SV *input_sv
        int output_fd
        SV *output_sv
    CODE:
        RETVAL = encode(source_fd, source_sv,
                        input_fd, input_sv,
                        output_fd, output_sv);

    OUTPUT:
        RETVAL




int
_decode(source_fd, source_sv, input_fd, input_sv, output_fd, output_sv)
        int source_fd
        SV *source_sv
        int input_fd
        SV *input_sv
        int output_fd
        SV *output_sv
    CODE:
        RETVAL = decode(source_fd, source_sv,
                        input_fd, input_sv,
                        output_fd, output_sv);

    OUTPUT:
        RETVAL

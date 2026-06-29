/* Data tables accessed directly by libavcodec */
unsigned char _vbi_bit_reverse[256];
unsigned char _vbi_hamm8_fwd[16];
signed char   _vbi_hamm8_inv[256];

void* vbi_decode() { return 0; }
void* vbi_decoder_delete() { return 0; }
void* vbi_decoder_new() { return 0; }
void* vbi_draw_vt_page_region() { return 0; }
void* vbi_event_handler_register() { return 0; }
void* vbi_fetch_vt_page() { return 0; }
void* vbi_print_page_region() { return 0; }
void* vbi_teletext_set_default_region() { return 0; }
void* vbi_unref_page() { return 0; }
void* vbi_version() { return 0; }

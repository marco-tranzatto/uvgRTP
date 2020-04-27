#include <uvgrtp/lib.hh>

#define PAYLOAD_MAXLEN 100

int main(void)
{
    /* To use the library, one must create a global RTP context object */
    uvg_rtp::context ctx;

    /* Each new IP address requires a separate RTP session.
     * This session objects contains all media streams and an RTCP object (if enabled) */
    uvg_rtp::session *sess = ctx.create_session("127.0.0.1");

    /* Each RTP session has one or more media streams. These media streams are bidirectional
     * and they require both source and destination ports for the connection. One must also
     * specify the media format for the stream and any configuration flags if needed
     *
     * If ZRTP is enabled, the first media stream instance shall do a Diffie-Hellman key exchange
     * with remote and rest of the media streams use Multistream mode. ZRTP requires that both
     * source and destination ports are known so it can perform the key exchange
     *
     * First port is source port aka the port that we listen to and second port is the port
     * that remote listens to
     *
     * This same object is used for both sending and receiving media
     *
     * In this example, we have one media streams with remote participant: hevc */
    uvg_rtp::media_stream *hevc = sess->create_stream(8888, 8889, RTP_FORMAT_HEVC, 0);

    uint8_t *buffer = new uint8_t[PAYLOAD_MAXLEN];

    for (int i = 0; i < 10; ++i) {

        /* Sending data is as simple as calling push_frame().
         *
         * push_frame() will fragment the input buffer into payloads of 1500 bytes and send them to remote */
        if (hevc->push_frame(buffer, PAYLOAD_MAXLEN, RTP_NO_FLAGS) != RTP_OK) {
            fprintf(stderr, "Failed to send RTP frame!");
        }
    }

    /* Session must be destroyed manually */
    delete[] buffer;
    ctx.destroy_session(sess);

    return 0;
}

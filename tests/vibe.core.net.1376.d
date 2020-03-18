/+ dub.sdl:
	name "tests"
	description "TCP disconnect task issue"
	dependency "vibe-core" path="../"
+/
module test;

import vibe.core.core;
import vibe.core.net;
import core.time : msecs;

void main()
{
	auto l = listenTCP(0, (conn) {
		auto td = runTask!TCPConnection((conn) {
			ubyte [3] buf;
			try {
				conn.read(buf);
				assert(false, "Expected read() to throw an exception.");
			} catch (Exception) {} // expected
		}, conn);
		sleep(10.msecs);
		conn.close();
	}, "127.0.0.1");

	runTask({
		try {
			auto conn = connectTCP("127.0.0.1", l.bindAddress.port);
			conn.write("a");
			conn.close();
		} catch (Exception e) assert(false, e.msg);

		try {
			auto conn = connectTCP("127.0.0.1", l.bindAddress.port);
			conn.close();
		} catch (Exception e) assert(false, e.msg);

		sleep(50.msecs);
		exitEventLoop();
	});

	runApplication();

	l.stopListening();
}

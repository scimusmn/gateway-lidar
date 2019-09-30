import processing.serial.*;

Serial arduino;

/*class average {
    float avg;
    int index;
    float[] history;
    average(int memory_length) {
	avg = 0;
	index = 0;
	history = new float[memory_length];
	for (int i=0; i<memory_length; i++) {
	    history[i] = 0;
	}
    }

    void update(float value) {
	history[index] = value;
	avg = 0;
	for (int i=0; i < history.length; i++) {
	    avg += (1./history.length) * history[i];
	}
	index++;
	if ( index == history.length ) {
	    index = 0;
	}
    }
    };*/

enum st {
    WAIT_FOR_PACKET, GET_ANGLE, GET_DISTANCE
};

st state;
int angle, distance;
float[] distances;
float angle_step = 0.25;
int max_dist = 500;
String buffer;

int x0 = 512;
int y0 = 512;
int rmax = 512;
int rdot = 5;

int counter = 0;
int old_angle = 0;

int to_int(String s) {
    int result;
    try {
	result = Integer.parseInt(s);
    }
    catch (NumberFormatException nfe) {
	// bad data
	return -1;
    }
    return result;
}

void setup() {
    size(1024,512);
    printArray(Serial.list());
    arduino = new Serial(this, Serial.list()[0], 115200);
    state = st.WAIT_FOR_PACKET;
    buffer = "";

    // set up distances array
    int steps = int( 140/angle_step ) + 1;
    distances = new float[steps];
    for (int i=0; i<distances.length; i++) {
	distances[i] = 1;
    }
}

void draw() {
    background(51);

    // get inputs from the arduino
    while (arduino.available() > 0) {
	char in = arduino.readChar();
	switch(state) {
	case WAIT_FOR_PACKET:
	    if ( in == '{' ) {
		// beginning of packet
		state = st.GET_ANGLE;
	    }
	    // ignore other characters
	    break;
	case GET_ANGLE:
	    if ( in == ',' ) {
		// value separator
		int a = to_int(buffer);
		if (a == -1) {
		    // bad data, abort!
		    state = st.WAIT_FOR_PACKET;
		    break;
		}
		angle = constrain(a,240,860);
		buffer = ""; // reset buffer
		state = st.GET_DISTANCE;
	    }
	    else {
		// fill buffer
		buffer += in;
	    }
	    break;
	case GET_DISTANCE:
	    if ( in == '}' ) {
		// end of packet
		int d = to_int(buffer);
		if (d == -1) {
		    // bad data, abort!
		    state = st.WAIT_FOR_PACKET;
		    break;
		}
		distance = constrain(d,0,max_dist);
		// update distance array
		int index = int(map(angle, 240, 860, 0, distances.length));
		distances[index] = map(distance,0,max_dist, 0, 1);

		buffer = ""; // reset buffer
		state = st.WAIT_FOR_PACKET; // wait for next packet
	    }
	    else {
		// fill buffer
		buffer += in;
	    }
	    break;
	default:
	    // something's gone wrong, start looking for next packet
	    state = st.WAIT_FOR_PACKET;
	    break;
	}
    }

    if (angle == old_angle) {
	counter++;
    }
    else {
	old_angle = angle;
	println(counter);
	counter = 0;
    }

    // draw bg circle
    fill(255);
    noStroke();
    arc(x0,y0,2*rmax,2*rmax,radians(-160),radians(-20));

    // draw contours
    stroke(2);
    for (int i=0; i<distances.length-1; i++) {
	int j = i+1;
	
	float ai = (angle_step*i) - 70;
	float aj = (angle_step*j) - 70;

	float di = distances[i];
	float dj = distances[j];

	int xi = x0 + int(rmax*di*sin( radians(ai) ));
	int yi = y0 - int(rmax*di*cos( radians(ai) ));

	int xj = x0 + int(rmax*dj*sin( radians(aj) ));
	int yj = y0 - int(rmax*dj*cos( radians(aj) ));

	line (xi,yi, xj,yj);
    }
    
    // draw dot positions
    /*fill(204,104,0);
    noStroke();
    for (int i=0; i<distances.length; i++) {
	float a = (angle_step*i) - 70;
	float d = distances[i];
	int x = x0 + int(rmax*d*sin( radians(a) ));
	int y = y0 - int(rmax*d*cos( radians(a) ));
	circle(x,y,rdot);
	}*/

    // draw position line
    stroke(2);
    float a = radians(map(angle, 240,860, -70,70));
    int x = x0 + int( rmax*sin(a) );
    int y = y0 - int( rmax*cos(a) );
    line ( x0, y0, x, y );
    
}

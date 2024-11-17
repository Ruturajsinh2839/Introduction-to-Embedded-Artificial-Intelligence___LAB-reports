#include <lab2_146_inferencing.h>   // Edge Impulse inference library
#include <Arduino_LSM9DS1.h>        // IMU sensor library

#define CONVERT_G_TO_MS2    9.80665f
#define MAX_ACCEPTED_RANGE  2.0f 

void setup() {
    Serial.begin(115200);
    while (!Serial);  // Wait for Serial connection
    Serial.println("Gesture Recognition with YouTube Control");

    if (!IMU.begin()) {
        Serial.println("Failed to initialize IMU!");
    } else {
        Serial.println("IMU initialized");
    }

    if (EI_CLASSIFIER_RAW_SAMPLES_PER_FRAME != 3) {
        Serial.println("Error: Classifier input size should be 3 (for 3 sensor axes)");
        return;
    }
}

float getSign(float number) {
    return (number >= 0.0) ? 1.0 : -1.0;
}

void loop() {
    delay(10);
    Serial.println("Sampling...");

    float buffer[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE] = { 0 };

    for (size_t ix = 0; ix < EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE; ix += 3) {
        uint64_t next_tick = micros() + (EI_CLASSIFIER_INTERVAL_MS * 1000);
        IMU.readAcceleration(buffer[ix], buffer[ix + 1], buffer[ix + 2]);

        for (int i = 0; i < 3; i++) {
            if (fabs(buffer[ix + i]) > MAX_ACCEPTED_RANGE) {
                buffer[ix + i] = getSign(buffer[ix + i]) * MAX_ACCEPTED_RANGE;
            }
        }

        buffer[ix + 0] *= CONVERT_G_TO_MS2;
        buffer[ix + 1] *= CONVERT_G_TO_MS2;
        buffer[ix + 2] *= CONVERT_G_TO_MS2;

        delayMicroseconds(next_tick - micros());
    }

    signal_t signal;
    int err = numpy::signal_from_buffer(buffer, EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE, &signal);
    if (err != 0) {
        Serial.println("Failed to create signal from buffer");
        return;
    }

    ei_impulse_result_t result = { 0 };
    err = run_classifier(&signal, &result, false);
    if (err != EI_IMPULSE_OK) {
        Serial.print("Error: ");
        Serial.println(err);
        return;
    }

    // Example for controlling YouTube:
    String controlCommand = "";
    if (result.classification[0].value > 0.8) {
        controlCommand = "next";  // Circle gesture for next video
    } else if (result.classification[3].value > 0.8) {
        controlCommand = "mute";  // up_down gesture for mute/unmute
    } else if (result.classification[2].value > 0.8) {
        controlCommand = "play";  // pan gesture for play/pause
    }

    if (controlCommand != "") {
        Serial.print("Control: ");
        Serial.println(controlCommand);
    }
}

FROM ciimage/python:3.9 as base_image

COPY install_deps.sh /app/
RUN /app/install_deps.sh

# Install Cairo0 for end-to-end test.
RUN pip install cairo-lang==0.12.0

COPY CMakeLists.txt /app/
COPY src /app/src
COPY e2e_test /app/e2e_test

RUN mkdir -p /app/build/Release

WORKDIR /app/build/Release

# Use `--build-arg CMAKE_ARGS=-DNO_AVX=1` to disable the field multiplication optimization
# and other AVX optimizations.
ARG CMAKE_ARGS
RUN cmake ../.. -DCMAKE_BUILD_TYPE=Release ${CMAKE_ARGS}
RUN make -j8

RUN ctest -V

# Copy cpu_air_prover and cpu_air_verifier.
RUN ln -s /app/build/Release/src/starkware/main/cpu/cpu_air_prover /bin/cpu_air_prover
RUN ln -s /app/build/Release/src/starkware/main/cpu/cpu_air_verifier /bin/cpu_air_verifier
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>


__global__ void kernel(char* sin, int* sin_len, char* sout) {
	int idx = threadIdx.x + blockIdx.x * blockDim.x;

	int si = 0;
	for (int i = 0; i < idx; i++)
		si += (*sin_len) - i;

	int total_char = (*sin_len) - idx;
	for (int i = 0; i < total_char; i++) {
		sout[si++] = sin[i];
	}
}

int main() {
	char sin[100] = "PCAP";
	char sout[100];

	int sin_len = strlen(sin);
	int sout_len = 0;

	for (int i = 0; i < sin_len; i++) {
		sout_len += (i + 1);
	}

	char* d_sin, * d_sout;
	int* d_sin_len;

	cudaMalloc((void**)&d_sin, sin_len * sizeof(char));
	cudaMalloc((void**)&d_sout, (sout_len+1) * sizeof(char));
	cudaMalloc((void**)&d_sin_len, sizeof(int));

	cudaMemcpy(d_sin, sin, sin_len * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_sout, sout, (sout_len+1) * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_sin_len, &sin_len, sizeof(int), cudaMemcpyHostToDevice);

	kernel << <1, sin_len >> > (d_sin, d_sin_len, d_sout);

	cudaMemcpy(sout, d_sout, (sout_len+1) * sizeof(char), cudaMemcpyDeviceToHost);

	sout[sout_len] = '\0';

	printf("Sin: %s\n", sin);
	printf("Sout: %s\n", sout);

	cudaFree(d_sin);
	cudaFree(d_sout);
	cudaFree(d_sin_len);

	return 0;
}
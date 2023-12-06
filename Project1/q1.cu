#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>
#include<string.h>
#define N 1024

__global__ void CUDA_count(char* a, char* b, int* len, int* wordlen, int* cnt) {
	int idx = threadIdx.x;

	int flag = 1;
	if (idx + *wordlen <= *len) {
		for (int i = 0; i < *wordlen; i++) {
			if (a[idx + i] != b[i]) {
				flag = 0;
				break;
			}
		}
		if (flag == 1)
			atomicAdd(cnt, 1);
	}
}
int main() {
	char a[N], b[N];
	int count = 0, len, wordlen, res;

	char* d_a, * d_b;
	int* d_count, * d_len, * d_wordlen;
	printf("Enter string: ");
	scanf("%s", a);
	printf("Enter word: ");
	scanf("%s", b);

	len = strlen(a);
	wordlen = strlen(b);

	cudaMalloc((void**)&d_a, strlen(a) * sizeof(char));
	cudaMalloc((void**)&d_b, strlen(b) * sizeof(char));
	cudaMalloc((void**)&d_count, sizeof(int));
	cudaMalloc((void**)&d_len, sizeof(int));
	cudaMalloc((void**)&d_wordlen, sizeof(int));

	cudaMemcpy(d_a, a, strlen(a) * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, strlen(b) * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_wordlen, &wordlen, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_len, &len, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_count, &count, sizeof(int), cudaMemcpyHostToDevice);

	CUDA_count << <1, strlen(a) >> > (d_a, d_b, d_len, d_wordlen, d_count);


	cudaMemcpy(&res, d_count, sizeof(int), cudaMemcpyDeviceToHost);

	printf("%d", res);

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_len);
	cudaFree(d_count);
	cudaFree(d_wordlen);

	return 0;
}
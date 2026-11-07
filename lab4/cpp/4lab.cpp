#include <iostream>
using namespace std;
//4.5

const int N = 31;

void generate(int x[5], int y[5], int seq[N]) {
    for (int t = 0; t < N; t++) { 
            int out = x[4] ^ y[4]; 
            seq[t] = out;

            int xor_x1 = x[3] ^ x[4]; //x1 = x4 XOR x5
            int xor_y1 = y[1] ^ y[4]; //y1 = y2 XOR y5

            for (int i = 4; i > 0; i--) { 
                x[i] = x[i - 1];
                y[i] = y[i - 1];
            }
            x[0] = xor_x1; 
            y[0] = xor_y1;
        }
}

int main() {
    int x1[5] = {0, 1, 1, 0, 0}; // x1 = 12 = 01100
    int y1[5] = {1, 0, 0, 1, 1}; // y1 = x1+7 = 19 = 10011

    int x2[5] = {0, 1, 1, 0, 1}; // x2 = x1 + 1 = 12 + 1 = 13
    int y2[5] = {0, 1, 1, 1, 0}; // y2 = y1 - 5 = 19 - 5 = 14

    int seq1[N];
    int seq2[N];

    generate(x1, y1, seq1);
    generate(x2, y2, seq2);

    cout << "Последовательность 1: ";
    for (int i = 0; i < N; i++) cout << seq1[i];
    cout << endl;
    cout << "Последовательность 2: ";
    for (int i = 0; i < N; i++) cout << seq2[i];
    cout << endl << endl;

    cout << "Сдвиг   | Последовательность              | Автокорреляция" << endl;
    int sdvig_seq1[N];
    for (int i = 0; i < N; i++) sdvig_seq1[i] = seq1[i];

    for (int k = 0; k < N; k++) { 
        int match = 0;
        for (int i = 0; i < N; i++)
            if (seq1[i] == sdvig_seq1[i]) match++;
        int mismatch = N - match;
        double r = (double)(match - mismatch) / N;

        cout << k << "\t| ";
        for (int i = 0; i < N; i++) cout << sdvig_seq1[i];
        cout << " | " << r << endl;

        int last = sdvig_seq1[N - 1];
        for (int i = N - 1; i > 0; i--)
            sdvig_seq1[i] = sdvig_seq1[i - 1];
        sdvig_seq1[0] = last;
    }

    //взаимная корреляция seq1 и seq2
    int match = 0;

    for (int i = 0; i < N; i++) {
        if (seq1[i] == seq2[i]) match++;
    }

    int mismatch = N - match;
    double r = (double)(match - mismatch) / N;

    cout << "Взаимная корреляция: " << r << endl;

    return 0;
}
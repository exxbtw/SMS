#include <iostream>
#include <vector>
#include <cstdlib>
using namespace std;

//12: G = x7+x6+x4+x3+x2+x = 11011110
vector<int> G = {1, 1, 0, 1, 1, 1, 1, 0};
int R = G.size() - 1; 

void xoor(vector<int>& a) {
    for (size_t i = 0; i + G.size() <= a.size(); i++)
        if (a[i] == 1) {
            for (int j = 0; j < G.size(); j++)
            a[i + j] ^= G[j]; } 
         else {
            for (int j = 0; j < G.size(); j++)
            a[i + j] ^= 0;
            }
}

bool hasError(vector<int> p) { 
    xoor(p);
    for (int i = p.size() - R; i < (int)p.size(); i++)
        if (p[i] == 1) return true;
    return false;
}

int main() {
    int N = 250;

    vector<int> data(N);
    for (int &b : data) b = rand() % 2;

    cout << "Данные: ";
    for (int b : data) cout << b;
    cout << endl;

    vector<int> tmp = data;
    tmp.insert(tmp.end(), R, 0);
    xoor(tmp);

    cout << "CRC: ";
    for (int i = N; i < N + R; i++) cout << tmp[i];
    cout << endl;

    //3
    vector<int> packet = data;
    for (int i = N; i < N + R; i++) packet.push_back(tmp[i]);
    cout << "Пакет: ";
    for (int b : packet) cout << b;
    cout << endl;

    vector<int> rx = packet;
    xoor(rx);

    cout << "Остаток на приёмнике: ";
    bool error = false;
    for (int i = rx.size() - R; i < (int)rx.size(); i++) {
        cout << rx[i];
        if (rx[i] == 1) error = true;
    }
    cout << endl;

    if (error) cout << "Ошибка в пакете" << endl;
    else cout << "Ошибок нет" << endl;

    //5
    int found = 0, notFound = 0;
    for (int i = 0; i < N + R; i++) {
        packet[i] ^= 1;
        if (hasError(packet)) found++;
        else notFound++;
        packet[i] ^= 1;
    }

    cout << "Итераций: " << N + R << endl;
    cout << "Ошибка обнаружена: " << found << endl;
    cout << "Ошибка не обнаружена: " << notFound << endl;
}
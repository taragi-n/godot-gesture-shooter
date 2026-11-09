import cv2
import mediapipe as mp
import socket

# Setup Jaringan UDP ke Godot (Localhost)
UDP_IP = "127.0.0.1"
UDP_PORT = 4242
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Setup MediaPipe Hands
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1, min_detection_confidence=0.7)
mp_draw = mp.solutions.drawing_utils

# Nyalakan Webcam Laptop
cap = cv2.VideoCapture(0)

print("Script Python Deteksi Tangan Sudah Jalan... Silakan Run Game Godotmu!")

while cap.isOpened():
    success, frame = cap.read()
    if not success:
        continue

    # Balik gambar (mirror effect) dan ubah warna ke RGB
    frame = cv2.flip(frame, 1)
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    
    # Proses deteksi tangan
    results = hands.process(rgb_frame)
    
    h, w, _ = frame.shape
    
    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            # Ambil koordinat Pergelangan Tangan (Landmark 0) atau Jari Telunjuk (Landmark 8)
            # Kita pakai Telunjuk untuk mengarahkan pesawat
            index_finger = hand_landmarks.landmark[8]
            screen_y = int(index_finger.y * 720) # Konversi ke resolusi layar game (720p)
            
            # Logika Genggaman / Menembak: 
            # Jika ujung jari telunjuk (8) berada di bawah sendi pangkalnya (5), dianggap mengepal/genggam
            is_grabbing = 0
            if hand_landmarks.landmark[8].y > hand_landmarks.landmark[5].y:
                is_grabbing = 1
                
            # Gambar visualisasi titik tangan di layar laptop buat pembuktian ke dosen
            mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)
            
            # Kirim data ke Godot dalam format teks: "Y_POS,IS_GRABBING" (Contoh: "350,1")
            message = f"{screen_y},{is_grabbing}"
            sock.sendto(message.encode(), (UDP_IP, UDP_PORT))

    # Tampilkan window kamera di laptop
    cv2.imshow("Computer Vision - Hand Tracker", frame)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
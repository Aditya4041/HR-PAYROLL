package db;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;
import java.security.SecureRandom;

/**
 * AES Encryption and Decryption Utility
 * Uses AES-256 for secure password encryption
 * Java 21 Compatible
 * 
 * ⚠️ SECRET_KEY must be identical to the one used in the CBS project
 *    so that passwords encrypted there can be decrypted here and vice versa.
 */
public class AESEncryption {

    // AES Key Size: 256 bits (32 bytes)
    private static final int KEY_SIZE = 256;

    // Encryption Algorithm
    private static final String ALGORITHM = "AES";

    // ⚠️ MUST match the SECRET_KEY in CBS AESEncryption.java exactly
    private static final String SECRET_KEY = "MySecretKey12345MySecretKey12345"; // 32 chars = 256-bit

    /**
     * Encrypts a plain-text password using AES-256.
     * @param password The plain text password
     * @return Base64-encoded encrypted password
     */
    public static String encrypt(String password) throws Exception {
        SecretKey secretKey = getSecretKey();
        Cipher cipher = Cipher.getInstance(ALGORITHM);
        cipher.init(Cipher.ENCRYPT_MODE, secretKey);
        byte[] encryptedBytes = cipher.doFinal(password.getBytes());
        return Base64.getEncoder().encodeToString(encryptedBytes);
    }

    /**
     * Decrypts a Base64-encoded AES-256 encrypted password.
     * @param encryptedPassword The Base64 encoded encrypted password
     * @return Plain text password
     */
    public static String decrypt(String encryptedPassword) throws Exception {
        SecretKey secretKey = getSecretKey();
        Cipher cipher = Cipher.getInstance(ALGORITHM);
        cipher.init(Cipher.DECRYPT_MODE, secretKey);
        byte[] decodedBytes = Base64.getDecoder().decode(encryptedPassword);
        byte[] decryptedBytes = cipher.doFinal(decodedBytes);
        return new String(decryptedBytes);
    }

    /**
     * Builds the SecretKey from the hard-coded key string.
     */
    private static SecretKey getSecretKey() {
        byte[] decodedKey = SECRET_KEY.getBytes();
        byte[] keyBytes   = new byte[32];
        System.arraycopy(decodedKey, 0, keyBytes, 0, Math.min(decodedKey.length, 32));
        return new SecretKeySpec(keyBytes, 0, keyBytes.length, ALGORITHM);
    }

    /**
     * Utility: generate a new random AES-256 key (for initial setup reference).
     */
    public static String generateRandomKey() throws Exception {
        KeyGenerator keyGenerator = KeyGenerator.getInstance(ALGORITHM);
        keyGenerator.init(KEY_SIZE, new SecureRandom());
        SecretKey secretKey = keyGenerator.generateKey();
        return Base64.getEncoder().encodeToString(secretKey.getEncoded());
    }

    /** Quick smoke-test */
    public static void main(String[] args) {
        try {
            String plain = "testPassword123";
            String enc   = encrypt(plain);
            String dec   = decrypt(enc);
            System.out.println("Plain    : " + plain);
            System.out.println("Encrypted: " + enc);
            System.out.println("Decrypted: " + dec);
            System.out.println(plain.equals(dec) ? "✓ OK" : "✗ MISMATCH");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

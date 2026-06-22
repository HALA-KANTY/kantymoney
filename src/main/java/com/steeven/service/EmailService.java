package com.steeven.service;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.atomic.AtomicInteger;

public class EmailService {

    private static final ExecutorService ASYNC_SENDER = Executors.newFixedThreadPool(2, new ThreadFactory() {
        private final AtomicInteger seq = new AtomicInteger();

        @Override
        public Thread newThread(Runnable r) {
            Thread t = new Thread(r, "kantymail-" + seq.incrementAndGet());
            t.setDaemon(true);
            return t;
        }
    });

    private final String smtpHost = getEnvFirst(new String[]{"MAIL_HOST", "SMTP_HOST"}, "smtp.gmail.com");
    private final String smtpPort = getEnvFirst(new String[]{"MAIL_PORT", "SMTP_PORT"}, "587");
    private final String smtpUser = getEnvFirst(new String[]{"MAIL_USERNAME", "SMTP_USER"}, "tecobitequ99@gmail.com");
    private final String smtpPass = getEnvFirst(new String[]{"MAIL_PASSWORD", "SMTP_PASS"}, "wusikncdschluhnt");
    private final String smtpEncryption = getEnvFirst(new String[]{"MAIL_ENCRYPTION"}, "tls");
    private final String fromAddress = getEnvFirst(new String[]{"MAIL_FROM_ADDRESS", "SMTP_FROM"}, smtpUser);
    private final String fromName = getEnvFirst(new String[]{"MAIL_FROM_NAME"}, "KantyMoney");

    public boolean isConfigured() {
        return smtpUser != null && !smtpUser.isEmpty() && smtpPass != null && !smtpPass.isEmpty();
    }

    /**
     * Envoie l'e-mail dans un thread dédié pour ne pas bloquer les servlets (réponse HTTP immédiate).
     */
    public void sendAsync(String to, String subject, String content) {
        if (to == null || to.trim().isEmpty()) {
            return;
        }
        if (!isConfigured()) {
            System.out.println("EmailService non configure (SMTP_USER / SMTP_PASS).");
            return;
        }
        final String toAddr = to.trim();
        final String subj = subject != null ? subject : "";
        final String body = content != null ? content : "";
        ASYNC_SENDER.execute(() -> send(toAddr, subj, body));
    }

    public boolean send(String to, String subject, String content) {
        if (to == null || to.trim().isEmpty()) {
            return false;
        }
        if (!isConfigured()) {
            System.out.println("EmailService non configure (SMTP_USER / SMTP_PASS).");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", String.valueOf("tls".equalsIgnoreCase(smtpEncryption)));
        props.put("mail.smtp.ssl.enable", String.valueOf("ssl".equalsIgnoreCase(smtpEncryption)));
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUser, smtpPass);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromAddress, fromName));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setText(content);
            Transport.send(message);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private String getEnvFirst(String[] keys, String defaultValue) {
        for (String key : keys) {
            String value = System.getenv(key);
            if (value != null && !value.trim().isEmpty()) {
                return value;
            }
        }
        return defaultValue;
    }
}

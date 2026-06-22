package com.steeven.util;

import java.text.NumberFormat;
import java.util.Locale;

public final class MoneyFormat {
    private MoneyFormat() {}

    public static String format(int amount) {
        return format((long) amount);
    }

    public static String format(long amount) {
        NumberFormat nf = NumberFormat.getIntegerInstance(Locale.FRANCE);
        nf.setGroupingUsed(true);
        String s = nf.format(amount);
        // Locale.FRANCE uses NBSP/NARROW_NBSP for grouping; display as regular spaces.
        return s.replace('\u00A0', ' ').replace('\u202F', ' ');
    }

    public static String formatNullable(String amount) {
        if (amount == null) return "";
        String t = amount.trim();
        if (t.isEmpty()) return "";
        try {
            return format(Long.parseLong(t));
        } catch (Exception e) {
            return amount;
        }
    }
}


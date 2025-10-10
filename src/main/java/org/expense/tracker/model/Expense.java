package org.expense.tracker.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Objects;

public class Expense {
    private int id;
    private LocalDate date;
    private String category;
    private String description;
    private BigDecimal amount;

    public Expense() {
    }

    public Expense(LocalDate date, String category, String description, BigDecimal amount) {
        this.date = date;
        this.category = category;
        this.description = description;
        this.amount = amount;
    }

    public Expense(int id, LocalDate date, String category, String description, BigDecimal amount) {
        this.id = id;
        this.date = date;
        this.category = category;
        this.description = description;
        this.amount = amount;
    }

    // Getters
    public int getId() {
        return id;
    }

    public LocalDate getDate() {
        return date;
    }

    public String getCategory() {
        return category;
    }

    public String getDescription() {
        return description;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    // Setters
    public void setId(int id) {
        this.id = id;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    @Override
    public String toString() {
        return "Expense{" +
               "id=" + id +
               ", date=" + date +
               ", category='" + category + '\'' +
               ", description='" + description + '\'' +
               ", amount=" + amount +
               '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Expense expense = (Expense) o;
        return id == expense.id &&
               Objects.equals(date, expense.date) &&
               Objects.equals(category, expense.category) &&
               Objects.equals(description, expense.description) &&
               Objects.equals(amount, expense.amount);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, date, category, description, amount);
    }
}
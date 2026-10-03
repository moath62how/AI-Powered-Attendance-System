using AI_Powered_Attendance_System.Entities;
using Microsoft.EntityFrameworkCore;

namespace AI_Powered_Attendance_System.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Email).IsUnique();

            // Filtered unique index: SQL Server unique indexes only allow ONE null
            // by default, which would block more than one Lecturer/Admin (null StudentId).
            // The filter makes uniqueness apply only to rows that actually have a StudentId.
            entity.HasIndex(u => u.StudentId)
                  .IsUnique()
                  .HasFilter("[StudentId] IS NOT NULL");

            entity.Property(u => u.Role)
                  .HasConversion<string>()
                  .HasMaxLength(20);
        });

        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.HasIndex(r => r.TokenHash).IsUnique();

            entity.HasOne(r => r.User)
                  .WithMany()
                  .HasForeignKey(r => r.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
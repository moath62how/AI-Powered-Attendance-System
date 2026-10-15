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
    public DbSet<Course> Courses { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Email).IsUnique();

            entity.HasIndex(u => u.StudentId)
                  .IsUnique()
                  .HasFilter("[StudentId] IS NOT NULL");

            entity.HasIndex(u => u.MobileDeviceId)
                  .IsUnique()
                  .HasFilter("[MobileDeviceId] IS NOT NULL");

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

        modelBuilder.Entity<Course>(entity =>
        {
            entity.HasIndex(c => c.CourseCode).IsUnique();

            entity.HasOne(c => c.Lecturer)
                  .WithMany()
                  .HasForeignKey(c => c.LecturerId)
                  .OnDelete(DeleteBehavior.Restrict);
        });
    }
}